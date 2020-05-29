//
//  HoursLoggedView.swift
//  Liloc
//
//  Created by William Ma on 5/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class HoursLoggedView: UIView {

    private(set) var imageView: UIImageView!
    private(set) var textLabel: UILabel!

    var isDisabled: Bool = false {
        didSet {
            imageView.tintColor = isDisabled ? .systemGray : nil
            textLabel.textColor = isDisabled ? .systemGray : .secondaryLabel
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.width.height.equalTo(30)
        }

        textLabel = UILabel()
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(2)
            make.bottom.leading.trailing.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
