//
//  TogglCurrentTimeEntry.swift
//  Liloc
//
//  Created by William Ma on 6/14/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

enum TogglCurrentTimeEntry {

    case active(description: String?, project: TogglProject?, start: Date, tags: [TogglTag])
    case inactive

    init(description: String?,
         project: TogglProject?,
         start: Date,
         tags: [TogglTag]) {
        self = .active(description: description, project: project, start: start, tags: tags)
    }

}
