//
//  LLTitleSubtitleCell.swift
//  Liloc
//
//  Created by William Ma on 5/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class LLTitleSubtitleCell: UITableViewCell {

    let titleLabel: UILabel
    let subtitleLabel: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(frame: .zero)
        subtitleLabel = UILabel(frame: .zero)

        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        titleLabel.setContentHuggingPriority(.defaultLow + 2, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh + 2, for: .vertical)
        titleLabel.font = .preferredFont(forTextStyle: .body)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
        }

        subtitleLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

