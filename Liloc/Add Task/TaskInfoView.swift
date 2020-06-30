//
//  TaskInfoView.swift
//  Liloc
//
//  Created by William Ma on 6/30/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class TaskInfoView: EntityPropertyView {

    let textView: EntityTaskTextContentView = EntityTaskTextContentView(placeholder: "text")
    let dateView: EntityTaskTextContentView = EntityTaskTextContentView(fillImage: nil, strokeImage: UIImage(named: "Calendar"), placeholder: "date")
    let projectView: EntityProjectPickerContentView
    let labelView: EntityLabelPickerContentView
    let priorityView = TodoistPriorityPickerContentView()

    init(projects: [TodoistProject], labels: [TodoistLabel]) {
        self.projectView = EntityProjectPickerContentView(projects: projects.map {
            .init(color: UIColor(todoistId: $0.color), name: $0.name ?? "")
        })
        self.labelView = EntityLabelPickerContentView(labels: labels.map {
            .init(tintColor: UIColor(todoistId: $0.color), title: $0.name ?? "")
        })
        super.init(contentViews: [textView, dateView, projectView, labelView, priorityView])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func focus(_ property: TaskTextProcessor.TaskProperty) {
        textView.setExpanded(property == .content, animated: true)
        dateView.setExpanded(property == .date, animated: true)
        projectView.setExpanded(property == .project, animated: true)
        labelView.setExpanded(property == .label, animated: true)
        priorityView.setExpanded(property == .priority, animated: true)
    }

}
