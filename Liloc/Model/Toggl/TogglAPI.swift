//
//  TogglAPI.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log
import Alamofire
import Combine
import Foundation

enum TogglError: Error {
    case projectNotFound(pid: Int64)
    case invalidDateFormat(receivedString: String)
}

class TogglAPI {

    private static let autoupdateInterval: TimeInterval = 15

    private struct TogglAPIResponse<T: Decodable>: Decodable {
        let data: T
    }

    private let username: String
    private let password: String

    private let dao: CoreDataDAO

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// YYYY-MM-DD
    private static let dayIso8601DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        dateFormatter.timeZone = .current
        return dateFormatter
    }()

    /// YYYY-MM-DDTHH:MM:SS+TT:TT
    private static let rfc3339DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        dateFormatter.timeZone = .current
        return dateFormatter
    }()

    private let apiToken = CurrentValueSubject<String?, Never>(nil)
    private let workspaceId = CurrentValueSubject<Int64?, Never>(nil)

    private var cancellables: Set<AnyCancellable> = []

    private var autoupdateTimer: Timer?
    private var autoupdateAPITokenCancellable: AnyCancellable?
    @Cached<TogglCurrentTimeEntry>(timeToLive: 5) private var cachedTimeEntry
    let currentTimeEntry = CurrentValueSubject<TogglCurrentTimeEntry, Never>(.inactive)

    init(dao: CoreDataDAO, username: String, password: String) {
        self.username = username
        self.password = password

        self.dao = dao
    }

    func sync(completion: @escaping (Error?) -> Void) {
        let parameters: Parameters = [
            "with_related_data": "true"
        ]

        let credentials = "\(username):\(password)".data(using: .utf8)
        let base64Credentials = credentials?.base64EncodedString() ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64Credentials)"
        ]

        AF.request(
            "https://www.toggl.com/api/v8/me",
            parameters: parameters,
            headers: headers).response { response in

                guard case let .success(.some(data)) = response.result else {
                    completion(nil)
                    return
                }

                do {
                    let response = try self.decoder.decode(
                        TogglAPIResponse<TogglJSONUserData>.self,
                        from: data)
                    let data = response.data
                    try self.syncProjects(data.projects)

                    self.apiToken.send(data.api_token)
                    self.workspaceId.send(data.default_wid)

                    completion(nil)
                } catch {
                    completion(error)
                }
        }
    }

    private func syncProjects(_ jsonProjects: [TogglJSONProject]) throws {
        var encountered: Set<TogglProject> = []
        for jsonProject in jsonProjects where jsonProject.active {
            let project = try dao.fetch(TogglProject.self, id: jsonProject.id)

            project.id = jsonProject.id
            project.color = jsonProject.color
            project.name = jsonProject.name

            if project.report == nil {
                project.report = dao.new(TogglProjectReport.self)
                project.report?.id = UUID()
            }

            encountered.insert(project)
        }

        let projects = try dao.fetchAll(TogglProject.self)
        for project in projects where !encountered.contains(project) {
            dao.delete(project)
        }

        try dao.saveContext()
    }

    func syncReports(
        _ project: TogglProject,
        referenceDate: Date,
        _ completion: @escaping (Error?) -> Void) {

        self.apiToken.sink { apiToken in
            guard let apiToken = apiToken else {
                return
            }

            self.workspaceId.sink { workspaceId in
                guard let workspaceId = workspaceId else {
                    return
                }

                self.syncReports(
                    project,
                    referenceDate: referenceDate,
                    apiToken: apiToken,
                    workspaceId: workspaceId,
                    completion: completion)

            }.store(in: &self.cancellables)
        }.store(in: &self.cancellables)
    }

    private func syncReports(
        _ project: TogglProject,
        referenceDate: Date,
        apiToken: String,
        workspaceId: Int64,
        completion: @escaping (Error?) -> Void) {

        let day = TogglAPI.dayIso8601DateFormatter.string(from: referenceDate)
        let parameters: Parameters = [
            "user_agent": "liloc (dot) app (at) gmail (dot) com",
            "workspace_id": workspaceId,
            "since": day,
            "until": day,
            "project_ids": [project.id]
        ]

        let credentials = "\(apiToken):api_token".data(using: .utf8)
        let base64Credentials = credentials?.base64EncodedString() ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64Credentials)"
        ]

        AF.request(
            "https://toggl.com/reports/api/v2/summary",
            parameters: parameters,
            headers: headers).response { response in

                guard case let .success(.some(data)) = response.result else {
                    completion(nil)
                    return
                }

                do {
                    let response = try self.decoder.decode(
                        TogglJSONReport.self,
                        from: data)

                    project.report?.referenceDate = referenceDate
                    project.report?.timeToday = response.total_grand ?? 0

                    try self.dao.saveContext()

                    completion(nil)
                } catch {
                    completion(error)
                }
        }
    }

    func startAutoupdateTimer() {
        guard autoupdateAPITokenCancellable == nil else { return }

        autoupdateAPITokenCancellable = apiToken.sink { [weak self] apiToken in
            guard let self = self, let apiToken = apiToken else { return }

            self.autoupdateTimer?.invalidate()
            self.autoupdateTimer = Timer.scheduledTimer(withTimeInterval: TogglAPI.autoupdateInterval, repeats: true) { _ in
                TogglAPI.getCurrentTimeEntry(dao: self.dao, apiToken: apiToken, decoder: self.decoder) { result in
                    switch result {
                    case let .success(timeEntry): self.currentTimeEntry.send(timeEntry)
                    case .failure: break
                    }
                }
            }
            self.autoupdateTimer?.fire()
        }
    }

    func getCurrentTimeEntry(
        useCache: Bool = true,
        _ callback: @escaping (Result<TogglCurrentTimeEntry, Error>) -> Void) {

        if useCache, let timeEntry = cachedTimeEntry {
            callback(.success(timeEntry))
        }

        var cancellable: AnyCancellable? = nil
        cancellable = self.apiToken.sink { [weak self] apiToken in
            guard let self = self, let apiToken = apiToken else { return }

            TogglAPI.getCurrentTimeEntry(dao: self.dao, apiToken: apiToken, decoder: self.decoder) { result in
                cancellable?.cancel()
                callback(result)
            }
        }
    }

    private static func getCurrentTimeEntry(
        dao: CoreDataDAO,
        apiToken: String,
        decoder: JSONDecoder = .init(),
        _ callback: @escaping (Result<TogglCurrentTimeEntry, Error>) -> Void) {

        os_log(.debug, "Refreshing current time entry from Toggl")

        let credentials = "\(apiToken):api_token".data(using: .utf8)
        let base64Credentials = credentials?.base64EncodedString() ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(base64Credentials)"
        ]

        AF.request(
            "https://www.toggl.com/api/v8/time_entries/current",
            headers: headers).response { response in

                switch response.result {
                case let .success(.some(data)):
                    do {
                        let response = try decoder.decode(
                            TogglAPIResponse<TogglJSONTimeEntry>.self,
                            from: data)
                        let data = response.data

                        guard let start = self.rfc3339DateFormatter.date(from: data.start) else {
                            callback(.failure(TogglError.invalidDateFormat(receivedString: data.start)))
                            return
                        }

                        let project = try data.pid.map { try dao.get(TogglProject.self, id: $0) } ?? nil
                        let tags = try data.tags?.map(dao.fetchTogglTag) ?? []

                        let timeEntry = TogglCurrentTimeEntry.active(
                            description: data.description,
                            project: project,
                            start: start,
                            tags: tags)

                        callback(.success(timeEntry))
                    } catch {
                        callback(.failure(error))
                    }

                case .success(nil):
                    callback(.success(.inactive))

                case let .failure(error):
                    callback(.failure(error))
                }
        }
    }

}
