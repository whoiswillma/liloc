//
//  TaskTextProcessorTest.swift
//  LilocTests
//
//  Created by William Ma on 3/31/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import XCTest
@testable import Liloc

class TaskTextProcessorTest: XCTestCase {

    private typealias Property = TaskTextProcessor.TaskProperty
    private typealias Result = TaskTextProcessor.Result

    func testEmpty() {
        let processor = TaskTextProcessor(projects: [], labels: [], priorities: [])
        XCTAssertEqual(
            .content,
            processor.process("").focusedProperty)
    }

    func testContentAndDateInteraction() {
        let processor
            = TaskTextProcessor(projects: [], labels: [], priorities: [])

        XCTAssertEqual(
            .content,
            processor.process("blah").focusedProperty)
        XCTAssertEqual(
            .date,
            processor.process("blah &").focusedProperty)
        XCTAssertEqual(
            .date,
            processor.process("blah &blih").focusedProperty)
        XCTAssertEqual(
            .content,
            processor.process("blah &blih&").focusedProperty)
        XCTAssertEqual(
            .content,
            processor.process("blah &blih& bleh").focusedProperty)
    }

    func testContentAndProjectInteraction() {
        let processor
            = TaskTextProcessor(
                projects: ["MATH", "PHIL", "PHYS"],
                labels: [],
                priorities: [])

        XCTAssertEqual(
            .content,
            processor.process("blah").focusedProperty)
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0, 1, 2]),
            processor.process("blah #"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("blah #M"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("blah #MATH"))
        XCTAssertEqual(
            .content,
            processor.process("blah #MATH4").focusedProperty)
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [1, 2]),
            processor.process("blah #MATH4 #P"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [2]),
            processor.process("blah #MATH4 #PHY"))
        XCTAssertEqual(
            .content,
            processor.process("blah #MATH4 #PHY bleh").focusedProperty)
    }

    func testProjectCaseInsensitive() {
        let processor
            = TaskTextProcessor(
                projects: ["mAtH"],
                labels: [],
                priorities: [])

        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("#M"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("#Ma"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("#Mat"))
        XCTAssertEqual(
            Result(focusedProperty: .project, availableIndexes: [0]),
            processor.process("#MatH"))
    }

}
