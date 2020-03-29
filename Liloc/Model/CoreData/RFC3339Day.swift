//
//  RFC3339Day.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

struct RFC3339Day {

    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter
    }()

    let string: String
    let date: Date

    init?(string: String) {
        guard let date = RFC3339Day.formatter.date(from: string) else {
            return nil
        }

        self.string = string
        self.date = date
    }

    init(date: Date) {
        self.string = RFC3339Day.formatter.string(from: date)
        self.date = date
    }

}

extension RFC3339Day: Equatable {

    static func ==(lhs: RFC3339Day, rhs: RFC3339Day) -> Bool {
        return lhs.string == rhs.string
    }

}

extension RFC3339Day: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }

}
