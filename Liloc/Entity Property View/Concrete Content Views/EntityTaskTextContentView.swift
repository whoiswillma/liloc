//
//  EntityTaskTextContentView.swift
//  Liloc
//
//  Created by William Ma on 3/29/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SnapKit
import UIKit

class EntityTaskTextContentView: EntityContentView {

    private(set) var fillImageView: UIImageView!
    private(set) var strokeImageView: UIImageView!
    private(set) var textView: UITextView!

    init(fillImage: UIImage? = nil, strokeImage: UIImage? = UIImage(named: "Title"), placeholder: String) {
        super.init(frame: .zero)

        fillImageView = UIImageView(image: fillImage)

        strokeImageView = UIImageView(image: strokeImage)

        textView = UITextView(frame: .zero)
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

        strokeImageView.snp.makeConstraints { make in
            make.edges.equalTo(fillImageView)
        }

        collapsedLayout.append(contentsOf: fillImageView.snp.prepareConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        })
        collapsedLayout.append(contentsOf: textView.snp.prepareConstraints { make in
            make.leading.equalTo(fillImageView.snp.trailing).offset(16)
            make.top.bottom.trailing.equalToSuperview().inset(12)
        })

        expandedLayout.append(contentsOf: fillImageView.snp.prepareConstraints { make in
            make.top.equalTo(snp.topMargin)
            make.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(22)
        })
        expandedLayout.append(contentsOf: textView.snp.prepareConstraints { make in
            make.top.equalTo(fillImageView.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(12)
        })

        setExpanded(false, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willExpand() {
        textView.font = UIFont.preferredFont(forTextStyle: .title1).with(traits: [.traitBold])
    }

    override func willCollapse() {
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
    }

}

