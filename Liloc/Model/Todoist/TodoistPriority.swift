//
//  TodoistPriority.swift
//  Liloc
//
//  Created by William Ma on 4/2/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

/// The priority of a task in Todoist
///
/// _Why are the raw values in reverse order of the case names?_
/// The Todoist API represents the highest priority with the number (4), but
/// the client represents it as "Priority 1".
enum TodoistPriority: Int64, CaseIterable {

    /// The highest priority
    case one = 4

    /// The second-highest priority
    case two = 3

    /// The third-highest priority
    case three = 2

    /// The lowest priority
    case four = 1

    var displayPriority: Int {
        switch self {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        }
    }

    init?(displayPriority: Int) {
        switch displayPriority {
        case 1: self = .one
        case 2: self = .two
        case 3: self = .three
        case 4: self = .four
        default: return nil
        }
    }

    var shortDescription: String {
        return "!\(displayPriority)"
    }

    var longDescription: String {
        return "Priority \(displayPriority)"
    }

    var color: UIColor? {
        switch self {
        case .one: return UIColor(named: "Priority1")
        case .two: return UIColor(named: "Priority2")
        case .three: return UIColor(named: "Priority3")
        case .four: return UIColor(named: "Priority4")
        }
    }

}
