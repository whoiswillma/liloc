//
//  UIHDivider.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class UIHDivider: UIView {

    init(height: CGFloat = 1 / UIScreen.main.scale, color: UIColor = .systemGray3) {
        super.init(frame: .zero)

        backgroundColor = color
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
