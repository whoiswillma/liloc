//
//  TogglAPIObjects.swift
//  Liloc
//
//  Created by William Ma on 4/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

struct TogglJSONUserData: Decodable {
    let id: Int64
    let api_token: String
    let default_wid: Int64
    let projects: [TogglJSONProject]
}

struct TogglJSONProject: Decodable {
    let id: Int64
    let wid: Int64
    let name: String
    let active: Bool
    let color: String
}
