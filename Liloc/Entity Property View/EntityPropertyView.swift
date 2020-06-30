//
//  EntityPropertyView.swift
//  Liloc
//
//  Created by William Ma on 3/29/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit
import os.log

class EntityPropertyView: UIView {

    private var stackView: UIStackView!

    let contentViews: [EntityContentView]

    init(contentViews: [EntityContentView]) {
        self.contentViews = contentViews

        super.init(frame: .zero)

        backgroundColor = .systemBackground
        layer.cornerRadius = 16

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true

        guard !contentViews.isEmpty else {
            os_log(.error, "contentViews is empty! %@", #function)
            return
        }

        for view in contentViews[0..<contentViews.count - 1] {
            stackView.addArrangedSubview(view)
            stackView.addArrangedSubview(UIHDivider())
        }

        stackView.addArrangedSubview(contentViews.last!)

//        textView = EntityTaskTextContentView(placeholder: "text")
//        stackView.addArrangedSubview(textView)
//
//
//        dateView = EntityTaskTextContentView(fillImage: nil, strokeImage: UIImage(named: "Calendar"), placeholder: "date")
//        stackView.addArrangedSubview(dateView)
//
//        stackView.addArrangedSubview(UIHDivider())
//
//        projectView = EntityProjectPickerContentView(projects: projects)
//        stackView.addArrangedSubview(projectView)
//
//        stackView.addArrangedSubview(UIHDivider())
//
//        labelView = EntityLabelPickerContentView(labels: labels)
//        stackView.addArrangedSubview(labelView)
//
//        stackView.addArrangedSubview(UIHDivider())
//
//        priorityView = TodoistPriorityPickerContentView()
//        stackView.addArrangedSubview(priorityView)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
