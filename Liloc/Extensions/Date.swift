//
//  Date.swift
//  Liloc
//
//  Created by William Ma on 5/27/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

extension Date {

    func sameDay(as other: Date) -> Bool {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(other, matchesComponents: components)
    }

}
