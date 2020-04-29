//
//  TodoistJSONObject.swift
//  Liloc
//
//  Created by William Ma on 3/25/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TodoistJSONResponse: Decodable {
    let full_sync: Bool
    let projects: [TodoistJSONProject]?
    let items: [TodoistJSONItem]?
    let labels: [TodoistJSONLabel]?
    let sync_token: String
    let sync_status: JSON?
}

struct TodoistJSONProject: Decodable {
    let id: Int64
    let name: String
    let color: Int64
    let parent_id: Int64?
    let child_order: Int64?
    let collapsed: Int64?
    let shared: Bool?
    let is_deleted: Int64?
    let is_archived: Int64?
    let is_favorite: Int64?
    let inbox_project: Bool?
    let team_inbox: Bool?
}

struct TodoistJSONItem: Decodable {
    let id: Int64
    let user_id: Int64
    let project_id: Int64
    let content: String
    let due: TodoistJSONDate?
    let priority: Int64?
    let parent_id: Int64?
    let child_order: Int64?
    let section_id: Int64?
    let day_order: Int64?
    let collapsed: Int64?
    let checked: Int64?
    let in_history: Int64?
    let is_deleted: Int64?
    let date_completed: String?
    let date_added: String
}

struct TodoistJSONLabel: Decodable {
    let id: Int64
    let name: String
    let color: Int64
    let item_order: Int64
    let is_deleted: Int64
    let is_favorite: Int64
}

struct TodoistJSONDate: Decodable {
    let date: String
    let timezone: String?
    let string: String
    let lang: String
    let is_recurring: Bool
}

enum TodoistHTTPCommandType: String, Encodable {
    case itemClose = "item_close"
    case itemAdd = "item_add"
}

struct TodoistHTTPCommand: Encodable {
    let type: TodoistHTTPCommandType
    let uuid: UUID
    let args: JSON
    let temp_id: UUID?
}
