//
//  UIVDivider.swift
//  Liloc
//
//  Created by William Ma on 3/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class UIVDivider: UIView {

    init(width: CGFloat = 1 / UIScreen.main.scale) {
        super.init(frame: .zero)

        backgroundColor = .systemGray3
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
