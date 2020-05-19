//
//  TodoistAPI.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Alamofire
import CoreData
import SwiftyJSON

class TodoistAPI {

    struct TodoistError: LocalizedError {
        let message: String
        let tag: String

        var errorDescription: String? {
            message
        }
    }

    private static let sync = URL(string: "https://api.todoist.com/sync/v8/sync")!

    private let dao: CoreDataDAO

    private let token: String

    private var syncToken: String?

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(dao: CoreDataDAO, token: String) {
        self.dao = dao
        self.token = token
    }

}

extension TodoistAPI {

    func closeTask(id: Int64, completion: @escaping (Error?) -> Void) {
        let uuid = UUID()
        let commands = [
            TodoistHTTPCommand(type: .itemClose, uuid: uuid, args: ["id": id], temp_id: nil)
        ]

        let parameters: Parameters

        do {
            parameters = [
                "token": token,
                "commands": String(data: try encoder.encode(commands), encoding: .utf8)!
            ]
        } catch {
            completion(error)
            return
        }

        requestAndSync(uuid: uuid, parameters: parameters, completion: completion)
    }

    func addTask(
        content: String,
        due: String?,
        project: TodoistProject?,
        labels: [TodoistLabel]?,
        priority: TodoistPriority?,
        completion: @escaping (Error?) -> Void) {

        let uuid = UUID()

        let args: [String: Any?] = [
            "content": content,
            "due": due.map { JSON(["string": $0]) },
            "project_id": project?.id,
            "labels": labels?.map(\.id),
            "priority": priority?.rawValue
        ]

        let commands = [
            TodoistHTTPCommand(type: .itemAdd, uuid: uuid, args: JSON(args), temp_id: UUID())
        ]

        let parameters: Parameters

        do {
            parameters = [
                "token": token,
                "commands": String(data: try encoder.encode(commands), encoding: .utf8)!
            ]
        } catch {
            completion(error)
            return
        }

        requestAndSync(uuid: uuid, parameters: parameters, completion: completion)
    }

    private func requestAndSync(
        uuid: UUID,
        parameters: Parameters,
        completion: @escaping (Error?) -> Void) {

        AF.request(TodoistAPI.sync, parameters: parameters).response { response in
            guard case let .success(.some(data)) = response.result else {
                if let error = response.error {
                    completion(error)
                }
                return
            }

            do {
                let response = try self.decoder.decode(TodoistJSONResponse.self, from: data)

                guard let sync_status = response.sync_status,
                    sync_status[uuid.uuidString] == "ok"
                    else
                {
                    let syncStatus = response.sync_status?[uuid.uuidString]
                    let error: TodoistError
                    if let errorMessage = syncStatus?["error"].string,
                        let errorTag = syncStatus?["error_tag"].string {
                        error = TodoistError(message: errorMessage, tag: errorTag)
                    } else {
                        error = TodoistError(message: "Unknown Error", tag: "")
                    }
                    completion(error)
                    return
                }

                self.sync(full: false, completion: completion)

                try self.dao.saveContext()

                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

}

extension TodoistAPI {

    func sync(full: Bool, completion: @escaping (Error?) -> Void) {
        let parameters: Parameters = [
            "token": token,
            "sync_token": full ? "*" : syncToken ?? "*",
            "resource_types": #"["projects", "items", "labels"]"#
        ]

        AF.request(TodoistAPI.sync, parameters: parameters).response { response in
            guard case let .success(.some(data)) = response.result else {
                if let error = response.error {
                    completion(error)
                }
                return
            }

            do {
                let response = try self.decoder.decode(TodoistJSONResponse.self, from: data)
                self.syncToken = response.sync_token

                try self.sync(response.projects ?? [], fullSync: response.full_sync)
                try self.sync(response.items ?? [], fullSync: response.full_sync)
                try self.sync(response.labels ?? [], fullSync: response.full_sync)

                try self.dao.saveContext()

                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    private func sync<T: TodoistSyncable>(_ jsonObjects: [T], fullSync: Bool) throws {
        typealias Entity = T.CoreDataEntity

        if fullSync {
            var alive: Set<Entity> = []

            for jsonObject in jsonObjects {
                let entity = try dao.fetch(Entity.self, id: jsonObject.id)

                if jsonObject.isAlive {
                    try jsonObject.update(entity, dao: dao)
                    alive.insert(entity)
                }
            }

            let entities: [Entity] = try dao.moc.fetch(Entity.fetchRequest()) as? [Entity] ?? []
            for entity in entities where !alive.contains(entity) {
                dao.delete(entity)
            }
        } else {
            for jsonObject in jsonObjects {
                if let entity = try dao.get(Entity.self, id: jsonObject.id) {
                    if jsonObject.isAlive {
                        try jsonObject.update(entity, dao: dao)
                    } else {
                        dao.delete(entity)
                    }
                } else if jsonObject.isAlive {
                    let entity = Entity(context: dao.moc)
                    try jsonObject.update(entity, dao: dao)
                }
            }
        }
    }

}
