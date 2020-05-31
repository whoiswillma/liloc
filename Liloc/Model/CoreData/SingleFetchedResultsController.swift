//
//  SingleFetchedResultsController.swift
//  Liloc
//
//  Created by William Ma on 5/30/20.
//  Copyright © 2020 William Ma. All rights reserved.
//
//  Based on: https://github.com/fastred/SingleFetchedResultController

import CoreData
import Foundation

class SingleFetchedResultController<T: NSManagedObject> {

    enum ChangeType {
        case firstFetch
        case insert
        case update
        case delete
    }

    typealias OnChange = ((T, ChangeType) -> Void)

    private let predicate: NSPredicate
    private let managedObjectContext: NSManagedObjectContext
    private let onChange: OnChange
    private(set) var object: T? = nil

    public init(predicate: NSPredicate, managedObjectContext: NSManagedObjectContext, onChange: @escaping OnChange) {
        self.predicate = predicate
        self.managedObjectContext = managedObjectContext
        self.onChange = onChange

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(objectsDidChange(_:)),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func performFetch() throws {
        let fetchRequest = T.fetchRequest() as NSFetchRequest
        fetchRequest.predicate = predicate

        let results = try managedObjectContext.fetch(fetchRequest)
        if let result = results.first as? T {
            object = result
            onChange(result, .firstFetch)
        }
    }

    @objc private func objectsDidChange(_ notification: Notification) {
        updateCurrentObject(notification: notification, key: NSInsertedObjectsKey)
        updateCurrentObject(notification: notification, key: NSUpdatedObjectsKey)
        updateCurrentObject(notification: notification, key: NSDeletedObjectsKey)
    }

    private func updateCurrentObject(notification: Notification, key: String) {
        guard let allModifiedObjects = (notification as NSNotification).userInfo?[key] as? Set<NSManagedObject> else {
            return
        }

        let objectsWithCorrectType = Set(allModifiedObjects.filter { return $0 as? T != nil })
        let matchingObjects = NSSet(set: objectsWithCorrectType)
            .filtered(using: predicate) as? Set<NSManagedObject> ?? []

        guard let matchingObject = matchingObjects.first as? T,
            let changeType = changeType(fromKey: key) else {
            return
        }

        object = matchingObject
        onChange(matchingObject, changeType)
    }

    private func changeType(fromKey key: String) -> ChangeType? {
        switch key {
        case NSInsertedObjectsKey: return .insert
        case NSUpdatedObjectsKey: return .update
        case NSDeletedObjectsKey: return .delete
        default: return nil
        }
    }

}
