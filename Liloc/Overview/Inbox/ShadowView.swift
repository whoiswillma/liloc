//
//  ShadowView.swift
//  Liloc
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    private(set) var shadowManager: LLLayerShadowManager!

    init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground

        shadowManager = LLLayerShadowManager(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
