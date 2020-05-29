//
//  Optional.swift
//  Liloc
//
//  Created by William Ma on 5/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

infix operator ?< : ComparisonPrecedence

extension Optional where Wrapped: Comparable {

    static func ?< (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (_, .none): return false
        case (.none, _): return true
        case let (.some(left), .some(right)): return left < right
        }
    }

}
