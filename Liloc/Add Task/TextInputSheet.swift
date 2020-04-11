//
//  TextInputSheet.swift
//  Liloc
//
//  Created by William Ma on 3/29/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UITextView_Placeholder
import UIKit

class TextInputSheet: UIView {

    private(set) var contentView: UIView!

    private(set) var cancelButton: UIButton!
    private(set) var doneButton: UIButton!

    private(set) var tokenField: LLTokenField!

    init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        LLLayerShadowManager(layer: layer).setDefaultShadowProperties()

        contentView = UIView()

        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont
            .preferredFont(forTextStyle: .body)

        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont
            .preferredFont(forTextStyle: .body)
            .with(traits: [.traitBold])

        tokenField = LLTokenField()
        tokenField.placeholder = "what shall you do...?"
        tokenField.tokenTextColor = .white
        tokenField.tokenBackgroundColor = UIColor(named: "LilocBlue")!

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(20)
        }

        contentView.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(tokenField)
        tokenField.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
