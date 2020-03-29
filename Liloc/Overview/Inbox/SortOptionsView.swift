//
//  SortOptionsView.swift
//  Liloc
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SnapKit
import UIKit

class SortOptionsView<T: CaseIterable & CustomStringConvertible>: UIControl {

    private var headerView: UIView!
    private var optionButton: UIButton!

    private var optionsView: UIView!
    private var stackView: UIStackView!

    private(set) var selectedIndex: Int = 0
    var selectedOption: T {
        T.allCases[T.allCases.index(T.allCases.startIndex, offsetBy: selectedIndex)]
    }

    private var isExpanded: Bool = false
    private var expandedConstraint: Constraint!
    private var collapsedConstraint: Constraint!

    init() {
        super.init(frame: .zero)

        clipsToBounds = true
        backgroundColor = .systemBackground
        layer.cornerCurve = .continuous
        layer.borderWidth = 1

        headerView = UIView()

        optionButton = UIButton(type: .system)
        optionButton.setTitle(selectedOption.description, for: .normal)
        optionButton.setImage(UIImage(named: "ChevronDown"), for: .normal)
        optionButton.contentHorizontalAlignment = .leading
        optionButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        optionButton.addTarget(
            self,
            action: #selector(optionButtonPressed(_:)),
            for: .touchUpInside)
        optionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)

        optionsView = UIView()

        stackView = UIStackView()
        stackView.axis = .vertical
        for (i, option) in T.allCases.enumerated() {
            let selectOptionButton = UIButton(type: .system)
            selectOptionButton.tag = i
            selectOptionButton.setTitle(option.description, for: .normal)
            selectOptionButton.contentHorizontalAlignment = .leading
            selectOptionButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
            selectOptionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            selectOptionButton.addTarget(
                self,
                action: #selector(selectOptionButtonPressed(_:)),
                for: .touchUpInside)
            stackView.addArrangedSubview(selectOptionButton)
        }

        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        headerView.addSubview(optionButton)
        optionButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        addSubview(optionsView)
        optionsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        optionsView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(optionButton.titleLabel!.snp.leading)
        }

        optionsView.snp.prepareConstraints { make in
            collapsedConstraint = make.height.equalTo(0).constraint
            expandedConstraint = make.height.equalTo(stackView).constraint
        }
        collapsedConstraint.activate()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = headerView.bounds.height / 3
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        layer.borderColor = tintColor.withAlphaComponent(0.8).cgColor
    }

    private func setExpandedAnimated(_ expanded: Bool) {
        self.isExpanded = expanded

        UIView.performWithoutAnimation {
            optionButton.setImage(
                UIImage(named: expanded ? "ChevronUp" : "ChevronDown"),
                for: .normal)
            optionButton.layoutIfNeeded()
        }

        UIViewPropertyAnimator(duration: 0.35, dampingRatio: 1) {
            self.collapsedConstraint.isActive = !expanded
            self.expandedConstraint.isActive = expanded

            self.superview?.layoutIfNeeded()
        }.startAnimation()
    }

    @objc private func optionButtonPressed(_ sender: UIButton) {
        setExpandedAnimated(!isExpanded)
    }

    @objc private func selectOptionButtonPressed(_ sender: UIButton) {
        selectedIndex = sender.tag

        UIView.performWithoutAnimation {
            optionButton.setTitle(selectedOption.description, for: .normal)
            optionButton.layoutIfNeeded()
        }

        setExpandedAnimated(false)

        sendActions(for: .valueChanged)
    }

}
