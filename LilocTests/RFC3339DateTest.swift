//
//  RFC3339DateTest.swift
//  LilocTests
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation
import XCTest
@testable import Liloc

class RFC3339DateTest: XCTestCase {

    func testBasic() {
        XCTAssertEqual(
            RFC3339Date(date: Date(timeIntervalSince1970: 1481029200)).string,
            "2016-12-06T13:00:00Z"
        )

        XCTAssertEqual(
            RFC3339Date(string: "2016-12-06T13:00:00Z")!.date.timeIntervalSince1970,
            1481029200
        )
    }

}
