//
//  TaskCell.swift
//  Liloc
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    var priority: TodoistPriority! {
        didSet {
            completeButton.tintColor = priority.color
        }
    }

    private(set) var completeButton: UIButton!
    var isCompleted: Bool = false {
        didSet {
            completeButton.setImage(
                UIImage(named: isCompleted ? "CircleCheck" : "Circle"),
                for: .normal
            )

            completeButton.isUserInteractionEnabled = !isCompleted
        }
    }

    private(set) var contentLabel: UILabel!
    private(set) var leftSubtitleLabel: UILabel!
    private(set) var rightSubtitleLabel: UILabel!

    var didPressComplete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        completeButton = UIButton(type: .system)
        completeButton.setImage(UIImage(named: "Circle"), for: .normal)
        completeButton.addTarget(
            self,
            action: #selector(completeButtonPressed(_:)),
            for: .touchUpInside
        )
        completeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        contentLabel = UILabel()
        contentLabel.numberOfLines = 0

        leftSubtitleLabel = UILabel()
        leftSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        leftSubtitleLabel.textColor = .secondaryLabel
        leftSubtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        rightSubtitleLabel = UILabel()
        rightSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        rightSubtitleLabel.textColor = .secondaryLabel
        rightSubtitleLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)

        contentView.addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalTo(completeButton.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(leftSubtitleLabel)
        leftSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.leading.equalTo(contentLabel)
            make.bottom.equalToSuperview().inset(8)
        }

        contentView.addSubview(rightSubtitleLabel)
        rightSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.leading.equalTo(leftSubtitleLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }

        priority = .four
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func completeButtonPressed(_ sender: UIButton) {
        didPressComplete?()
    }

}
