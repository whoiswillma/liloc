//
//  Cached.swift
//  Liloc
//
//  Created by William Ma on 6/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

@propertyWrapper
class Cached<Value> {

    private var value: Value?
    private(set) var lastUpdated: Date?
    private let timeToLive: TimeInterval

    private let now: () -> Date

    init(timeToLive: TimeInterval, now: @escaping () -> Date = Date.init) {
        self.timeToLive = timeToLive
        self.now = now
    }

    var wrappedValue: Value? {
        get {
            if value != nil,
                let lastUpdated = lastUpdated,
                now().timeIntervalSince(lastUpdated) > timeToLive {
                value = nil
                return nil
            } else {
                return value
            }
        }
        set {
            value = newValue
            lastUpdated = now()
        }
    }

}
