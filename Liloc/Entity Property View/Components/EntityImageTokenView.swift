//
//  EntityImageTokenView.swift
//  Liloc
//
//  Created by William Ma on 4/3/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class EntityImageTokenView: UIView {

    private(set) var fillImageView: UIImageView!
    private(set) var strokeImageView: UIImageView!
    private(set) var tokenField: LLTokenField!

    init(fillImage: UIImage?, strokeImage: UIImage?, placeholder: String) {
        super.init(frame: .zero)

        fillImageView = UIImageView(image: fillImage)

        strokeImageView = UIImageView(image: strokeImage)

        tokenField = LLTokenField()
        tokenField.placeholder = placeholder
        tokenField.isEditable = false
        tokenField.font = .preferredFont(forTextStyle: .headline)
        tokenField.isScrollEnabled = false
        tokenField.isEditable = false

        addSubview(fillImageView)
        addSubview(strokeImageView)
        addSubview(tokenField)

        fillImageView.snp.makeConstraints { make in
            make.edges.equalTo(strokeImageView)
        }
        strokeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        tokenField.snp.makeConstraints { make in
            make.leading.equalTo(strokeImageView.snp.trailing).offset(16)
            make.top.trailing.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTokens(_ tokens: [String]) {
        tokenField.text = ""
        for token in tokens {
            tokenField.insertToken(at: (tokenField.text as NSString).length, text: token)
        }
    }

}
