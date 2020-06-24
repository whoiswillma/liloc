//
//  Secret.swift
//  Liloc
//
//  Created by William Ma on 6/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log
import Foundation

enum Secret {

    private static let propertyList: [String: String] = {
        if let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
            let contents = FileManager.default.contents(atPath: path) {
            return (try? PropertyListSerialization.propertyList(from: contents, options: .mutableContainersAndLeaves, format: nil)) as? [String: String] ?? [:]
        } else {
            return [:]
        }
    }()

    private static func getProperty(_ key: String) -> String {
        if let property = propertyList[key] {
            return property
        } else {
            os_log(.error, "Expected key %@ in the secrets plist, but could not be found.", key)
            return ""
        }
    }

    static let TODOIST_CLIENT_ID = Secret.getProperty("TODOIST_CLIENT_ID")
    static let TODOIST_CLIENT_SECRET = Secret.getProperty("TODOIST_CLIENT_SECRET")

}
