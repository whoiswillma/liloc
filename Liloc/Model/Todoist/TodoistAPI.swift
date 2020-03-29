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
            TodoistCommand(type: .itemClose, uuid: uuid, args: ["id": id])
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

        AF.request(TodoistAPI.sync, parameters: parameters).response { response in
            guard case let .success(dataOptional) = response.result,
                let data = dataOptional
                else
            {
                if let error = response.error {
                    completion(error)
                }
                return
            }

            do {
                let response = try self.decoder.decode(TodoistResponse.self, from: data)

                guard let sync_status = response.sync_status,
                    sync_status[uuid.uuidString] == "ok"
                    else
                {
                    fatalError()
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
            "resource_types": #"["projects", "items"]"#
        ]

        AF.request(TodoistAPI.sync, parameters: parameters).response { response in
            guard case let .success(dataOptional) = response.result, let data = dataOptional else {
                if let error = response.error {
                    completion(error)
                }
                return
            }

            do {
                let response = try self.decoder.decode(TodoistResponse.self, from: data)
                self.syncToken = response.sync_token

                try self.sync(response.projects ?? [], fullSync: response.full_sync)
                try self.sync(response.items ?? [], fullSync: response.full_sync)

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
