//
//  UIClosureBarButtonItem.swift
//  Liloc
//
//  Created by William Ma on 5/31/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class UIClosureBarButtonItem: UIBarButtonItem {

    private let actionClosure: () -> Void

    init(title: String?, style: UIBarButtonItem.Style, action: @escaping () -> Void) {
        self.actionClosure = action

        super.init()

        self.target = self
        self.action = #selector(performAction)
        self.title = title
        self.style = style
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func performAction() {
        actionClosure()
    }

}
