//
//  RFC3339DayTest.swift
//  LilocTests
//
//  Created by William Ma on 4/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation
import XCTest
@testable import Liloc

class RFC3339DayTest: XCTestCase {

    func testBasic() {
        XCTAssertEqual(
            RFC3339Day(date: Date(timeIntervalSince1970: 1481029200)).string,
            "2016-12-06"
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "GMT")!

        XCTAssertEqual(
            calendar.dateComponents([.year, .month, .day], from: RFC3339Day(string: "2016-12-06")!.date),
            DateComponents(year: 2016, month: 12, day: 6)
        )
    }

}
