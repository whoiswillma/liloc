//
//  TodoistSyncable.swift
//  Liloc
//
//  Created by William Ma on 4/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import Foundation

protocol CoreDataRepresentable {

    associatedtype CoreDataEntity: NSManagedObject

    func update(_ entity: CoreDataEntity, dao: CoreDataDAO) throws

}

protocol TodoistSyncable: CoreDataRepresentable {

    var id: Int64 { get }
    var isAlive: Bool { get }

}

extension TodoistJSONProject: TodoistSyncable {

    typealias CoreDataEntity = TodoistProject

    var isAlive: Bool {
        is_archived == 0 && is_deleted == 0
    }

    func update(_ project: TodoistProject, dao: CoreDataDAO) throws {
        project.childOrder = child_order ?? 0
        project.color = color
        project.id = id
        project.inboxProject = inbox_project ?? false
        project.isFavorite = is_favorite == 1
        project.name = name

        project.parent = try parent_id.map {
            try dao.fetch(TodoistProject.self, id: $0)
        }
    }

}

extension TodoistJSONItem: TodoistSyncable {

    typealias CoreDataEntity = TodoistTask

    var isAlive: Bool {
        checked == 0 && is_deleted == 0
    }

    func update(_ task: TodoistTask, dao: CoreDataDAO) throws {
        task.id = id
        task.content = content
        task.dateAdded = RFC3339Date(string: date_added)?.date

        if let jsonDue = due {
            let dueDate = dao.fetchDueDate(of: task)
            jsonDue.update(dueDate, dao: dao)
        } else {
            task.dueDate = nil
        }

        task.project = try dao.fetch(TodoistProject.self, id: project_id)
    }

}

extension TodoistJSONLabel: TodoistSyncable {

    typealias CoreDataEntity = TodoistLabel

    var isAlive: Bool {
        is_deleted == 0
    }

    func update(_ entity: TodoistLabel, dao: CoreDataDAO) throws {
        entity.id = id
        entity.name = name
        entity.color = color
        entity.itemOrder = item_order
        entity.isFavorite = is_favorite
    }

}

extension TodoistJSONDate: CoreDataRepresentable {

    typealias CoreDataEntity = TodoistDueDate

    func update(_ dueDate: TodoistDueDate, dao: CoreDataDAO) {
        dueDate.date = date
        dueDate.timezone = timezone
        dueDate.string = string
        dueDate.lang = lang
        dueDate.isRecurring = is_recurring
    }

}
