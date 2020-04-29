//
//  AddTaskController.swift
//  Liloc
//
//  Created by William Ma on 3/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log

import SnapKit
import SwiftUI
import UIKit

class AddTaskController: UIViewController {

    private enum Item: Hashable {
        case content(_ text: String, expanded: Bool)
    }

    private let dao: CoreDataDAO
    private let todoist: TodoistAPI

    private let projects: [TodoistProject]
    private let labels: [TodoistLabel]

    private let processor: TaskTextProcessor

    init(dao: CoreDataDAO, todoist: TodoistAPI) throws {
        self.dao = dao
        self.todoist = todoist
        self.projects = try dao.projects()
        self.labels = try dao.labels()

        let projectNames = self.projects.compactMap(\.name)
        let labelNames = self.labels.compactMap(\.name)
        self.processor = TaskTextProcessor(
            projects: projectNames,
            labels: labelNames,
            priorities: ["1", "2", "3", "4"])

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Views

    private var scrollView: UIScrollView!

    private var infoView: TaskInfoView!

    private var textInputSheet: TextInputSheet!
    private var textInputBottomMargin: NSLayoutConstraint!

    // Task Properties

    private var content: String? {
        didSet {
            loadViewIfNeeded()
            if let content = content, !content.isEmpty {
                infoView.textView.textView.text = content
                infoView.textView.strokeImageView.tintColor = nil // same tint color as superview
                textInputSheet.doneButton.isEnabled = true
            } else {
                infoView.textView.textView.text = nil
                infoView.textView.strokeImageView.tintColor = .systemGray
                textInputSheet.doneButton.isEnabled = false
            }
        }
    }

    private var date: String? {
        didSet {
            loadViewIfNeeded()
            if let date = date, !date.isEmpty {
                infoView.dateView.textView.text = date
                infoView.dateView.strokeImageView.tintColor = nil // same tint color as superview
            } else {
                infoView.dateView.textView.text = nil
                infoView.dateView.strokeImageView.tintColor = .systemGray
            }
        }
    }

    private var projectToken: (project: TodoistProject, token: UUID)? {
        didSet {
            loadViewIfNeeded()
            if let (project, _) = projectToken {
                infoView.projectView.imageTextView.textView.text = project.name
                infoView.projectView.imageTextView.strokeImageView.tintColor = nil
                infoView.projectView.imageTextView.fillImageView.tintColor = .clear
            } else {
                infoView.projectView.imageTextView.textView.text = nil
                infoView.projectView.imageTextView.strokeImageView.tintColor = .systemGray
                infoView.projectView.imageTextView.fillImageView.tintColor = .clear
            }
        }
    }

    private var labelTokens: [(TodoistLabel, UUID)] = [] {
        didSet {
            loadViewIfNeeded()
            let justLabels = labelTokens.compactMap(\.0.name)
            infoView.labelView.imageTokenView.setTokens(justLabels)
            infoView.labelView.imageTokenView.strokeImageView.tintColor = justLabels.isEmpty ? .systemGray : nil
            infoView.labelView.imageTokenView.fillImageView.tintColor = .clear
        }
    }

    private var priorityToken: (priority: Priority, token: UUID)? {
        didSet {
            loadViewIfNeeded()
            if let (priority, _) = priorityToken {
                infoView.priorityView.imageTextView.textView.text = priority.longDescription
                infoView.priorityView.imageTextView.strokeImageView.tintColor = priority.color
                infoView.priorityView.imageTextView.fillImageView.tintColor = priority.color?.darken()
            } else {
                infoView.priorityView.imageTextView.textView.text = nil
                infoView.priorityView.imageTextView.strokeImageView.tintColor = .systemGray
                infoView.priorityView.imageTextView.fillImageView.tintColor = .clear
            }
        }
    }

    // Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpScrollView()
        setUpStackView()
        setUpTextInputSheet()

        setUpKeyboardNotifications()

        clearContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textInputSheet.tokenField.becomeFirstResponder()
    }

    @objc private func keyboardFrameWillChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else
        {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
            .insetBy(
                dx: 0,
                dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        textInputBottomMargin.constant = intersection.height
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset.bottom = textInputSheet.frame.height
    }

    private func processInputText() {
        let tokenField = textInputSheet.tokenField!
        let ranges = tokenField.alternatingNormalTokenRanges()

        let textSegments: [TaskTextProcessor.TextSegment]
            = ranges.enumerated().map { index, range in
                index.isMultiple(of: 2) ? .text(range) : .token(range)
        }

        processor.process(
            tokenField.text as NSString,
            textSegments,
            cursor: tokenField.selectedRange.location)

        content = processor.content
            .components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        date = processor.date
            .components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")

        if processor.focusedProperty == .project {
            infoView.projectView.setAvailableItems(processor.availableIndexes, animated: false)
        } else if processor.focusedProperty == .label {
            infoView.labelView.setAvailableItems(processor.availableIndexes, animated: false)
        }

        infoView.focusProperty(processor.focusedProperty)
    }

    private func moveToken(_ oldToken: UUID?, toRange range: NSRange, replacingText text: String) -> UUID? {
        let tokenField = textInputSheet.tokenField!

        // Tokenize the new range before untokenizing the old range since
        // untokenizing may change the text and therefore the range will be
        // inaccurate

        let newToken = tokenField.tokenize(
            range,
            replacingTextWith: text)

        if let oldToken = oldToken {
            tokenField.untokenize(id: oldToken)
        }

        if let newToken = newToken {
            tokenField.moveCursor(toEndOf: newToken)
            tokenField.insertText(" ")
        }

        return newToken
    }

    private func infoViewDidSelectProject(_ index: Int) {
        guard let range = processor.focusedRange else {
            os_log(.error, "The focused range is missing")
            return
        }

        let project = projects[index]
        if let token = moveToken(
            projectToken?.1,
            toRange: range,
            replacingText: "#" + (project.name ?? "")) {

            projectToken = (project, token)
        } else {
            projectToken = nil
        }

        processInputText()
    }

    private func infoViewDidSelectLabel(_ index: Int) {
        guard let range = processor.focusedRange else {
            os_log(.error, "The focused range is missing")
            return
        }

        let tokenField = textInputSheet.tokenField!

        let label = labels[index]
        if let newToken = tokenField.tokenize(
            range,
            replacingTextWith: "@\(label.name ?? "")") {

            labelTokens.append((label, newToken))
        }

        processInputText()
    }

    private func infoViewDidSelectPriority(_ priority: Priority) {
        guard let range = processor.focusedRange else {
            os_log(.error, "The focused range is missing")
            return
        }

        if let token = moveToken(
            priorityToken?.1,
            toRange: range,
            replacingText: priority.shortDescription) {

            priorityToken = (priority: priority, token: token)
        }

        processInputText()
    }

    @objc private func doneButtonPressed(_ button: UIButton) {
        todoist.addTask(
            content: content ?? "No content",
            due: date,
            project: projectToken?.0,
            labels: labelTokens.map(\.0),
            priority: priorityToken?.0)
        { error in
            if let error = error {
                let alertController = UIAlertController(
                    title: "Unable to Add Task",
                    message: "Message from Todoist: \(error.localizedDescription)",
                    preferredStyle: .alert)
                alertController.addAction(
                    UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func cancelButtonPressed(_ button: UIButton) {
        if textInputSheet.tokenField.text.isEmpty {
            dismiss(animated: true)
            return
        }

        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(
            title: "Discard",
            style: .destructive)
        { _ in
            self.dismiss(animated: true)
        })

        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))

        present(alertController, animated: true)
    }

}

extension AddTaskController: LLTokenFieldDelegate {

    func tokenFieldDidChange(_ tokenField: LLTokenField) {
        processInputText()
    }

    func tokenFieldShouldReturn(_ tokenField: LLTokenField) -> Bool {
        switch processor.focusedProperty {
        case .project:
            if let index = processor.availableIndexes.min() {
                infoViewDidSelectProject(index)
            }

        case .priority:
            if let priorityString = processor.focusedSubstring {
                let indexSubstring = priorityString[
                    priorityString.index(after: priorityString.startIndex)...]
                if let index = Int(indexSubstring),
                    let priority = Priority(displayPriority: index) {

                    infoViewDidSelectPriority(priority)
                }
            }

        default:
            break
        }

        return false
    }

    func tokenField(_ tokenField: LLTokenField, didDeleteToken token: UUID) {
        if token == projectToken?.token {
            projectToken = nil
        } else if token == priorityToken?.token {
            priorityToken = nil
        } else if let index = labelTokens.firstIndex(where: { $1 == token }) {
            labelTokens.remove(at: index)
        }
    }

    private func clearContent() {
        content = nil
        date = nil
        projectToken = nil
        labelTokens = []
        priorityToken = nil
    }

}

extension AddTaskController {

    private func setUpView() {
        view.tintColor = UIColor(named: "LilocBlue")
        view.backgroundColor = .systemGroupedBackground
    }

    private func setUpScrollView() {
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setUpStackView() {
        infoView = TaskInfoView(projects: projects, labels: labels)

        infoView.projectView.didSelectProject = { [weak self] index in
            self?.infoViewDidSelectProject(index)
        }

        infoView.labelView.didSelectLabel = { [weak self] index in
            self?.infoViewDidSelectLabel(index)
        }

        infoView.priorityView.didSelectPriority = { [weak self] priority in
            self?.infoViewDidSelectPriority(priority)
        }

        scrollView.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(20)
            make.width.equalToSuperview().offset(-40)
        }
    }

    private func setUpTextInputSheet() {
        textInputSheet = TextInputSheet()
        textInputSheet.tokenField.tokenDelegate = self

        textInputSheet.doneButton.addTarget(
            self,
            action: #selector(doneButtonPressed(_:)),
            for: .touchUpInside)

        textInputSheet.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonPressed(_:)),
            for: .touchUpInside)

        view.addSubview(textInputSheet)
        textInputSheet.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        textInputBottomMargin = view.safeAreaLayoutGuide.bottomAnchor
            .constraint(equalTo: textInputSheet.contentView.bottomAnchor)
        textInputBottomMargin.isActive = true
    }

    private func setUpKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardFrameWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }

}
