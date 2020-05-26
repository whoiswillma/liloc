//
//  TogglAPI.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Alamofire
import Foundation

class TogglAPI {

    private struct TogglResponse<T: Decodable>: Decodable {
        let since: Int
        let data: T
    }

    private let username: String
    private let password: String

    private let dao: CoreDataDAO

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(dao: CoreDataDAO, username: String, password: String) {
        self.username = username
        self.password = password

        self.dao = dao
    }

    func sync(full: Bool, completion: @escaping (Error?) -> Void) {
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
                        TogglResponse<TogglJSONUserData>.self,
                        from: data)
                    let data = response.data
                    try self.syncProjects(data.projects)
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

            encountered.insert(project)
        }

        let projects = try dao.fetchAll(TogglProject.self)
        for project in projects where !encountered.contains(project) {
            dao.delete(project)
        }
    }

}
