//
//  CoreDataDAO.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData

class CoreDataDAO {

    private let container: NSPersistentContainer

    var moc: NSManagedObjectContext { container.viewContext }
    var psc: NSPersistentStoreCoordinator { container.persistentStoreCoordinator }

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func saveContext() throws {
        if moc.hasChanges {
            try moc.save()
        }
    }

    func get<T: NSManagedObject>(_ type: T.Type, id: Int64) throws -> T? {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))

        return try moc.fetch(request).first as? T
    }

    func fetch<T: NSManagedObject>(_ type: T.Type, id: Int64) throws -> T {
        try get(type, id: id) ?? T(context: moc)
    }

    func fetchAll<T: NSManagedObject>(_ type: T.Type) throws -> [T] {
        try moc.fetch(T.fetchRequest()) as? [T] ?? []
    }

    func delete(_ object: NSManagedObject) {
        moc.delete(object)
    }

}

// MARK: - Todoist

extension CoreDataDAO {

    func inboxProject() throws -> TodoistProject? {
        let request = TodoistProject.fetchRequest() as NSFetchRequest
        request.predicate = NSPredicate(format: "inboxProject == YES")
        return try moc.fetch(request).first
    }

    func projects() throws -> [TodoistProject] {
        let request = TodoistProject.fetchRequest() as NSFetchRequest
        return try moc.fetch(request)
    }

}

extension CoreDataDAO {

    func fetchDueDate(of task: TodoistTask) -> TodoistDueDate {
        if let dueDate = task.dueDate {
            return dueDate
        } else {
            let dueDate = TodoistDueDate(context: moc)
            task.dueDate = dueDate
            return dueDate
        }
    }

}

extension CoreDataDAO {

    func labels() throws -> [TodoistLabel] {
        let request = TodoistLabel.fetchRequest() as NSFetchRequest
        return try moc.fetch(request)
    }

}
