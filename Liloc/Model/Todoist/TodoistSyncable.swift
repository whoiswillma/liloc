//
//  TodoistSyncable.swift
//  Liloc
//
//  Created by William Ma on 3/25/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import Foundation

protocol TodoistCoreDataRepresentable {

    associatedtype CoreDataEntity: NSManagedObject

    func update(_ entity: CoreDataEntity, dao: CoreDataDAO) throws

}

protocol TodoistSyncable: TodoistCoreDataRepresentable {

    var id: Int64 { get }
    var isAlive: Bool { get }

}

extension TodoistProject: TodoistSyncable {

    typealias CoreDataEntity = Project

    var isAlive: Bool {
        is_archived == 0 && is_deleted == 0
    }

    func update(_ project: Project, dao: CoreDataDAO) throws {
        project.childOrder = child_order ?? 0
        project.color = color
        project.id = id
        project.inboxProject = inbox_project ?? false
        project.isFavorite = is_favorite == 1
        project.name = name

        project.parent = try parent_id.map {
            try dao.fetch(Project.self, id: $0)
        }
    }

}

extension TodoistItem: TodoistSyncable {

    typealias CoreDataEntity = Task

    var isAlive: Bool {
        checked == 0 && is_deleted == 0
    }

    func update(_ task: Task, dao: CoreDataDAO) throws {
        task.id = id
        task.content = content
        task.dateAdded = RFC3339Date(string: date_added)?.date

        if let jsonDue = due {
            let dueDate = dao.fetchDueDate(of: task)
            jsonDue.update(dueDate, dao: dao)
        } else {
            task.dueDate = nil
        }

        task.project = try dao.fetch(Project.self, id: project_id)
    }

}

extension TodoistDate: TodoistCoreDataRepresentable {

    typealias CoreDataEntity = DueDate

    func update(_ dueDate: DueDate, dao: CoreDataDAO) {
        dueDate.date = date
        dueDate.timezone = timezone
        dueDate.string = string
        dueDate.lang = lang
        dueDate.isRecurring = is_recurring
    }

}

