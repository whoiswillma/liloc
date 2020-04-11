//
//  TaskTextProcessor.swift
//  Liloc
//
//  Created by William Ma on 3/31/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

class TaskTextProcessor {

    enum TaskProperty: Equatable {
        case content
        case date
        case project
        case label
        case priority
    }

    enum TextSegment {
        case text(NSRange)
        case token(NSRange)
    }

    let projects: [String]
    let labels: [String]
    let priorities: [String]

    private(set) var focusedProperty: TaskProperty = .content
    private(set) var availableIndexes: Set<Int> = []
    private(set) var focusedRange: NSRange?
    private(set) var focusedSubstring: String?

    private(set) var content: String = ""
    private(set) var date: String = ""

    init(projects: [String], labels: [String], priorities: [String]) {
        self.projects = projects
        self.labels = labels
        self.priorities = priorities
    }

    private func reset() {
        focusedProperty = .content
        availableIndexes = []
        focusedRange = nil

        content = ""
        date = ""
    }

    func process(_ text: NSString, _ segments: [TextSegment], cursor: Int) {
        reset()

        var state: TaskProperty = .content
        var derivatives: [String?] = []

        var startOfCurrentState: Int = 0

        // Indicator that marks whether the contiguous text region with the same
        // state under the cursor should be stored as `focusedRange`
        var recordFocusedRange: Bool = false

        for segment in segments {
            switch segment {
            case let .text(range):
                text.enumerateSubstrings(in: range, options: .byComposedCharacterSequences) { character, range, _, _ in
                    guard let character = character else {
                        return
                    }

                    let oldState = state
                    self.step(character, state: &state, derivatives: &derivatives)
                    if oldState != state {
                        if recordFocusedRange {
                            let location = startOfCurrentState
                            let length = range.location - startOfCurrentState
                            self.focusedRange = NSRange(location: location, length: length)
                            recordFocusedRange = false
                        }

                        startOfCurrentState = range.location
                    }

                    if range.contains(cursor - 1) {
                        self.focusedProperty = state

                        self.availableIndexes = Set(derivatives
                            .enumerated()
                            .filter { $0.element != nil }
                            .map { $0.offset })

                        recordFocusedRange = true
                    }
                }

            case .token:
                continue
            }
        }

        if recordFocusedRange {
            let location = startOfCurrentState
            let length = text.length - startOfCurrentState
            let focusedRange = NSRange(location: location, length: length)
            self.focusedRange = focusedRange
            self.focusedSubstring = text.substring(with: focusedRange)
        }
    }

    private func step(_ character: String, state: inout TaskProperty, derivatives: inout [String?]) {
        switch state {
        case .content:
            switch character {
            case "{":
                state = .date

            case "#":
                derivatives = projects
                state = .project
                content.append(character)

            case "@":
                derivatives = labels
                state = .label
                content.append(character)

            case "!":
                derivatives = priorities
                state = .priority
                content.append(character)

            default:
                content.append(character)
            }

        case .date:
            switch character {
            case "}":
                state = .content

            default:
                date.append(character)

            }

        case .project, .label, .priority:
            derivatives = derivatives.map { string in
                if string == nil {
                    return nil
                } else if string!.isEmpty {
                    return nil
                } else {
                    var derivative = string!
                    if character.uppercased() == derivative.removeFirst().uppercased() {
                        return derivative
                    } else {
                        return nil
                    }
                }
            }

            if derivatives.allSatisfy({ $0 == nil }) {
                state = .content
            }

            content.append(character)
        }

    }

}
