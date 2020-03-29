//
//  RFC3339Date.swift
//  Liloc
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

struct RFC3339Date {

    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter
    }()

    let string: String
    let date: Date

    init?(string: String) {
        guard let date = RFC3339Date.formatter.date(from: string) else {
            return nil
        }

        self.string = string
        self.date = date
    }

    init(date: Date) {
        self.string = RFC3339Date.formatter.string(from: date)
        self.date = date
    }

}
