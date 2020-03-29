//
//  DueDate.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

extension DueDate {

    private static let rfc3339Day: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter
    }()

    var dayComponent: String? {
        guard let date = date else {
            return nil
        }

        if let tIndex = date.firstIndex(of: "T") {
            return String(date[..<tIndex])
        } else {
            return date
        }
    }

    var day: RFC3339Day? {
        dayComponent.flatMap { RFC3339Day(string: $0) }
    }

}
