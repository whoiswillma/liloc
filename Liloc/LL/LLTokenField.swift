//
//  LLTokenField.swift
//  Liloc
//
//  Created by William Ma on 3/30/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

protocol LLTokenFieldDelegate: AnyObject {

    func tokenFieldDidChange(_ tokenField: LLTokenField)

    func tokenFieldShouldReturn(_ tokenField: LLTokenField) -> Bool

    func tokenField(_ tokenField: LLTokenField, didDeleteToken token: UUID)

}

class LLTokenField: UITextView {

    static let tokenAttribute = NSAttributedString.Key(rawValue: "com.williamma.LLTokenField.tokenAttribute")

    private static let nonBreakingWhitespace = "\u{00a0}"

    private var tokenTextStorage: LLTokenTextStorage {
        textStorage as! LLTokenTextStorage
    }

    override var textColor: UIColor! {
        didSet { tokenTextStorage.textColor = textColor }
    }

    override var font: UIFont! {
        didSet { tokenTextStorage.font = font }
    }

    var tokenTextColor: UIColor {
        get { tokenTextStorage.tokenForegroundColor }
        set { tokenTextStorage.tokenForegroundColor = newValue }
    }

    var tokenBackgroundColor: UIColor {
        get { tokenTextStorage.tokenBackgroundColor }
        set { tokenTextStorage.tokenBackgroundColor = newValue }
    }

    weak var tokenDelegate: LLTokenFieldDelegate?

    init() {
        let textStorage = LLTokenTextStorage()
        let layoutManager = LLTokenLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: textContainer)

        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        textContainerInset = .zero
        isScrollEnabled = false
        font = .preferredFont(forTextStyle: .body)
        smartInsertDeleteType = .no
        smartDashesType = .no
        smartQuotesType = .no

        // Add space for the token background to extend beyond the bounds of the
        // text container. This is most noticable if you type an entire line of
        // text and have a token extend onto the new line
        textContainer.lineFragmentPadding = 0

//        textContainer.lineBreakMode = .byCharWrapping

        delegate = self
    }

    @discardableResult
    func insertToken(at index: Int, text: String) -> UUID {
        let tokenId = UUID()
        let attributes: [NSAttributedString.Key: Any] = [
            LLTokenField.tokenAttribute: tokenId
        ]
        let attributedString
            = NSAttributedString(
                string: "\(LLTokenField.nonBreakingWhitespace)\(text)\(LLTokenField.nonBreakingWhitespace)",
                attributes: attributes)
        tokenTextStorage.insert(attributedString, at: index)

        repositionCursorAtEndOfTokenRange()

        return tokenId
    }

    private func repositionCursorAtEndOfTokenRange() {
        let cursorLocation = selectedRange.location
        if let (_, range) = tokenTextStorage.token(locatedAt: cursorLocation) {
            selectedRange = NSRange(
                location: range.location + range.length,
                length: 0)
        }
    }

    @discardableResult
    func tokenize(_ range: NSRange, replacingTextWith replacement: String? = nil) -> UUID? {
        guard range.length != 0 else {
            return nil
        }

        let oldText = text as NSString
        tokenTextStorage.replaceCharacters(in: range, with: "")
        let tokenText = oldText.substring(with: range)
        return insertToken(at: range.location, text: replacement ?? tokenText)
    }

    private func deleteToken(id: UUID, notifyDelegate: Bool) {
        guard let range = tokenTextStorage.rangeOfToken(matching: id) else {
            return
        }

        textStorage.replaceCharacters(in: range, with: "")

        if notifyDelegate {
            tokenDelegate?.tokenField(self, didDeleteToken: id)
        }
    }

    @discardableResult
    func untokenize(id: UUID, notifyDelegate: Bool = false) -> NSRange? {
        guard let range = tokenTextStorage.rangeOfToken(matching: id) else {
            return nil
        }

        let oldText = text as NSString
        deleteToken(id: id, notifyDelegate: notifyDelegate)

        var text = oldText.substring(with: range)
        if text.hasPrefix(LLTokenField.nonBreakingWhitespace),
            text.hasSuffix(LLTokenField.nonBreakingWhitespace) {

            let contentStart = text.index(after: text.startIndex)
            let contentEnd = text.index(before: text.endIndex)
            text = String(text[contentStart..<contentEnd])
        }

        let attributedText = NSAttributedString(string: text)
        textStorage.insert(attributedText, at: range.location)
        let newRange = NSRange(location: range.location, length: attributedText.length)

        return newRange
    }

    /// Returns a list of ranges that partition `text` into segments that
    /// alternate between a normal-text range and a token range.
    ///
    /// # Postconditions:
    /// - When `text` is empty, the list with the range `(location: 0, length: 0)`
    /// is returned
    /// - The first range returned is always a normal range.
    /// - The ranges are disjoint
    /// - The ranges unioned equal the range of `text`
    func alternatingNormalTokenRanges() -> [NSRange] {
        let text = self.text as NSString
        if text.length == 0 {
            return [NSRange(location: 0, length: 0)]
        }

        let tokenRanges = tokenTextStorage
            .tokens()
            .map { $0.1 }
            .sorted { $0.location < $1.location }

        var ranges: [NSRange] = []
        var location: Int = 0
        for tokenRange in tokenRanges {
            let normalTextRange = NSRange(
                location: location,
                length: tokenRange.location - location)
            ranges.append(normalTextRange)
            ranges.append(tokenRange)
            location = tokenRange.upperBound
        }

        let lastRange = NSRange(
            location: location,
            length: text.length - location)
        ranges.append(lastRange)

        return ranges
    }

    func moveCursor(toEndOf token: UUID) {
        guard let range = tokenTextStorage.rangeOfToken(matching: token) else {
            return
        }

        selectedRange = NSRange(location: range.upperBound, length: 0)
    }

}

extension LLTokenField: UITextViewDelegate {

    func textViewDidChangeSelection(_ textView: UITextView) {
        var newSelectedRange: NSRange

        if selectedRange.length == 0 {
            let cursorLocation = selectedRange.location
            let newCursorLocation = nearestNormalText(to: cursorLocation)
            newSelectedRange = NSRange(location: newCursorLocation, length: 0)
        } else {
            let newCursorStart = nearestNormalText(to: selectedRange.lowerBound)
            let newCursorEnd = nearestNormalText(to: selectedRange.upperBound)
            newSelectedRange = NSRange(location: newCursorStart, length: newCursorEnd - newCursorStart)
        }

        if !NSEqualRanges(selectedRange, newSelectedRange) {
            selectedRange = newSelectedRange
        }
    }

    private func nearestNormalText(to location: Int) -> Int {
        if let (_, range) = tokenTextStorage.token(locatedAt: location) {
            if location > range.location + range.length / 2 {
                return range.upperBound
            } else {
                return range.lowerBound
            }
        } else {
            return location
        }
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        if text == "\n", let tokenDelegate = tokenDelegate {
            return tokenDelegate.tokenFieldShouldReturn(self)
        }

        if range.length == 1, text.isEmpty {
            if let (id, _) = tokenTextStorage.token(locatedAt: range.location) {
                if let range = untokenize(id: id, notifyDelegate: true) {
                    selectedRange = NSRange(location: range.upperBound, length: 0)
                }
                tokenDelegate?.tokenFieldDidChange(self)
                return false
            }
        } else if range.length > 0 {
            if !tokenTextStorage.isValidEditingRange(range) {
                return false
            }

            let tokens = tokenTextStorage.tokens(within: range)
            if !tokens.isEmpty {
                // TODO: Reduce complexity of O(n^2) algorithm

                tokenTextStorage.replaceCharacters(in: range, with: text)
                tokenDelegate?.tokenFieldDidChange(self)
                return false
            }
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        tokenDelegate?.tokenFieldDidChange(self)
    }

}

private class LLTokenTextStorage: NSTextStorage {

    var textColor: UIColor = .label
    var font: UIFont = .preferredFont(forTextStyle: .body)

    var tokenBackgroundColor: UIColor = .black
    var tokenForegroundColor: UIColor = .white

    private let backingStore = NSMutableAttributedString()

    override var string: String { backingStore.string }

    override func attributes(
        at location: Int,
        effectiveRange range: NSRangePointer?)
        -> [NSAttributedString.Key : Any]
    {
        backingStore.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(
            [.editedCharacters, .editedAttributes],
            range: range,
            changeInLength: (str as NSString).length - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(
            [.editedAttributes],
            range: range,
            changeInLength: 0)
        endEditing()
    }

    override func processEditing() {
        updateFormatting()

        super.processEditing()
    }

    private func updateFormatting() {
        addAttribute(.foregroundColor, value: textColor, range: editedRange)
        addAttribute(.font, value: font, range: editedRange)
        addAttribute(.kern, value: 0, range: editedRange)

        for (_, range) in tokens(within: editedRange) {
            let attributes: [NSAttributedString.Key: Any] = [
                .backgroundColor: tokenBackgroundColor,
                .foregroundColor: tokenForegroundColor
            ]

            addAttributes(attributes, range: NSRange(location: range.location + 1, length: range.length - 2))
            addAttributes([.kern: 3], range: NSRange(location: range.location, length: 1))
            addAttributes([.kern: 3], range: NSRange(location: range.location + range.length - 1, length: 1))
        }
    }

    private func enumerateTokens(
        intersecting range: NSRange? = nil,
        action: (UUID, NSRange) -> Bool) {

        enumerateAttribute(LLTokenField.tokenAttribute, in: range ?? NSRange(location: 0, length: length), options: []) { (value, range, stopPointer) in
            if let id = value as? UUID {
                stopPointer.pointee = ObjCBool(action(id, range))
            }
        }
    }

    func tokens(within range: NSRange? = nil) -> [(UUID, NSRange)] {
        var tokens: [(UUID, NSRange)] = []
        enumerateTokens(intersecting: range) { (id, range) -> Bool in
            tokens.append((id, range))
            return false
        }
        return tokens
    }

    func rangeOfToken(matching tokenId: UUID, intersecting range: NSRange? = nil) -> NSRange? {
        var result: NSRange?
        enumerateTokens(intersecting: range) { (id, range) -> Bool in
            if tokenId == id {
                result = range
                return true
            } else {
                return false
            }
        }
        return result
    }

    func token(locatedAt index: Int, intersecting range: NSRange? = nil) -> (UUID, NSRange)? {
        var result: (UUID, NSRange)?
        enumerateTokens(intersecting: range) { (id, range) -> Bool in
            if range.contains(index) {
                result = (id, range)
                return true
            } else {
                return false
            }
        }
        return result
    }

    func isValidEditingRange(_ range: NSRange) -> Bool {
        // We don't allow editing parts of tokens (ranges that partially overlap a token or are contained within a token)
        if range.length == 0 {
            return true
        }
        let editingRangeStart = range.location
        let editingRangeEnd = range.location + range.length
        for (_, range) in tokens() {
            let tokenRangeStart = range.location
            let tokenRangeEnd = range.location + range.length - 1
            if editingRangeStart > tokenRangeStart && editingRangeStart < tokenRangeEnd
                || editingRangeEnd > tokenRangeStart && editingRangeEnd < tokenRangeEnd {
                return false
            }
        }
        return true
    }

}

private class LLTokenLayoutManager: NSLayoutManager {

    override func fillBackgroundRectArray(
        _ rectArray: UnsafePointer<CGRect>,
        count rectCount: Int,
        forCharacterRange charRange: NSRange,
        color: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        context.setShouldAntialias(true)

        for i in 0..<rectCount {
            let backgroundRect = rectArray[i].insetBy(dx: -6, dy: 0)
            let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 4)
            path.fill()
        }

        context.restoreGState()
    }

}
