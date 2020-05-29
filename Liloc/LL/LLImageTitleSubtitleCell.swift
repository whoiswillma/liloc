//
//  LLImageTitleSubtitleCell.swift
//  Liloc
//
//  Created by William Ma on 6/14/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class LLImageTitleSubtitleCell: UITableViewCell {
    
    private let imageContainer: UIView
    let fillImageView: UIImageView
    let strokeImageView: UIImageView
    
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        imageContainer = UIView(frame: .zero)
        fillImageView = UIImageView(image: nil)
        strokeImageView = UIImageView(image: nil)
        titleLabel = UILabel(frame: .zero)
        subtitleLabel = UILabel(frame: .zero)
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(imageContainer)
        imageContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(imageContainer.snp.height)
        }
    
        fillImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        fillImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        fillImageView.contentMode = .scaleAspectFit
        imageContainer.addSubview(fillImageView)
        fillImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        strokeImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        strokeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        strokeImageView.contentMode = .scaleAspectFit
        imageContainer.addSubview(strokeImageView)
        strokeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        titleLabel.setContentHuggingPriority(.defaultLow + 2, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh + 2, for: .vertical)
        titleLabel.font = .preferredFont(forTextStyle: .body)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageContainer.snp.trailing).offset(8)
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
            make.leading.equalTo(imageContainer.snp.trailing).offset(8)
            make.bottom.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

