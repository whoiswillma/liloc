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
        return try get(type, id: id) ?? T(context: moc)
    }

    func delete(_ object: NSManagedObject) {
        moc.delete(object)
    }

}

extension CoreDataDAO {

    func inboxProject() throws -> Project? {
        let request = Project.fetchRequest() as NSFetchRequest
        request.predicate = NSPredicate(format: "inboxProject == YES")
        return try moc.fetch(request).first
    }

}

extension CoreDataDAO {

    func fetchDueDate(of task: Task) -> DueDate {
        if let dueDate = task.dueDate {
            return dueDate
        } else {
            let dueDate = DueDate(context: moc)
            task.dueDate = dueDate
            return dueDate
        }
    }

}
