//
//  PillView.swift
//  Liloc
//
//  Created by William Ma on 3/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class PillView: UIView {

    private(set) var leftButton: UIButton!
    private(set) var rightButton: UIButton!

    public init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        LLLayerShadowManager(layer: layer).setDefaultShadowProperties()

        leftButton = UIButton(type: .system)
        leftButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        leftButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        let divider = UIVDivider(width: 1)

        rightButton = UIButton(type: .system)
        rightButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        rightButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        addSubview(leftButton)
        leftButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.equalToSuperview()
            make.right.equalTo(snp.centerX)
        }

        addSubview(divider)
        divider.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }

        addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.equalTo(snp.centerX)
            make.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = bounds.height / 2

        layoutMargins = UIEdgeInsets(
            top: 0,
            left: cornerRadius,
            bottom: 0,
            right: cornerRadius)

        layer.cornerRadius = cornerRadius
    }

}
