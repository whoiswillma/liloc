//
//  EntityImageTextView.swift
//  Liloc
//
//  Created by William Ma on 4/3/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class EntityImageTextView: UIView {
    
    private(set) var fillImageView: UIImageView!
    private(set) var strokeImageView: UIImageView!
    private(set) var textView: UITextView!

    init(fillImage: UIImage?, strokeImage: UIImage?, placeholder: String) {
        super.init(frame: .zero)

        fillImageView = UIImageView(image: fillImage)

        strokeImageView = UIImageView(image: strokeImage)

        textView = UITextView()
        textView.placeholder = placeholder
        textView.font = .preferredFont(forTextStyle: .headline)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        addSubview(fillImageView)
        addSubview(strokeImageView)
        addSubview(textView)

        fillImageView.snp.makeConstraints { make in
            make.edges.equalTo(strokeImageView)
        }
        strokeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        textView.snp.makeConstraints { make in
            make.leading.equalTo(strokeImageView.snp.trailing).offset(16)
            make.top.trailing.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
