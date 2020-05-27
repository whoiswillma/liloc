//
//  TogglAPI.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log
import Alamofire
import Foundation

class TogglAPI {

    private struct TogglAPIResponse<T: Decodable>: Decodable {
        let data: T
    }

    private struct TogglReportsResponse: Decodable {
        let total_grand: Int64
    }

    private let username: String
    private let password: String

    private let dao: CoreDataDAO

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// YYYY-MM-DD
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        dateFormatter.timeZone = .current
        return dateFormatter
    }()

    private var apiToken: String?
    private var workspaceId: Int64?

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

                    self.apiToken = data.api_token
                    self.workspaceId = data.default_wid

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
            }

            encountered.insert(project)
        }

        let projects = try dao.fetchAll(TogglProject.self)
        for project in projects where !encountered.contains(project) {
            dao.delete(project)
        }

        try dao.saveContext()
    }

    func syncReports(_ project: TogglProject, referenceDate: Date = Date(), _ completion: @escaping (Error?) -> Void) {
        guard let workspaceId = workspaceId else {
            os_log(.error, "Attempted to sync reports while workspaceId was missing")
            return
        }

        guard let apiToken = apiToken else {
            os_log(.error, "Attempted to sync reports while apiToken was missing")
            return
        }

        let day = iso8601DateFormatter.string(from: referenceDate)
        let parameters: Parameters = [
            "user_agent": "liloc (dot) app (at) gmail (dot) com",
            "workspace_id": workspaceId,
            "since": day,
            "until": day
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
                        TogglReportsResponse.self,
                        from: data)

                    project.report?.referenceDate = referenceDate
                    project.report?.timeToday = response.total_grand

                    try self.dao.saveContext()

                    completion(nil)
                } catch {
                    completion(error)
                }
        }
    }

}
