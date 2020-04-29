//
//  TaskInfoView.swift
//  Liloc
//
//  Created by William Ma on 3/29/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class TaskInfoView: UIView {

    private var stackView: UIStackView!

    private(set) var textView: TaskTextContentView!
    private(set) var dateView: TaskTextContentView!
    private(set) var projectView: TaskProjectPickerContentView!
    private(set) var labelView: TaskLabelPickerContentView!
    private(set) var priorityView: TaskPriorityPickerContentView!

    private var contentViews: [TaskContentView] {
        [textView, dateView, projectView, labelView, priorityView]
    }

    init(projects: [TodoistProject], labels: [TodoistLabel]) {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        layer.cornerRadius = 16

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true

        textView = TaskTextContentView(fillImage: nil, strokeImage: UIImage(named: "Title"), placeholder: "text")
        stackView.addArrangedSubview(textView)

        stackView.addArrangedSubview(UIHDivider())

        dateView = TaskTextContentView(fillImage: nil, strokeImage: UIImage(named: "Calendar"), placeholder: "date")
        stackView.addArrangedSubview(dateView)

        stackView.addArrangedSubview(UIHDivider())

        projectView = TaskProjectPickerContentView(projects: projects)
        stackView.addArrangedSubview(projectView)

        stackView.addArrangedSubview(UIHDivider())

        labelView = TaskLabelPickerContentView(labels: labels)
        stackView.addArrangedSubview(labelView)

        stackView.addArrangedSubview(UIHDivider())

        priorityView = TaskPriorityPickerContentView()
        stackView.addArrangedSubview(priorityView)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func focusProperty(_ property: TaskTextProcessor.TaskProperty) {
        for view in contentViews {
            view.setExpanded(false, animated: true)
        }

        switch property {
        case .content: textView.setExpanded(true, animated: true)
        case .date: dateView.setExpanded(true, animated: true)
        case .project: projectView.setExpanded(true, animated: true)
        case .label: labelView.setExpanded(true, animated: true)
        case .priority: priorityView.setExpanded(true, animated: true)
        }
    }

}
