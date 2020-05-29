//
//  LLNestedImageView.swift
//  Liloc
//
//  Created by William Ma on 4/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class LLFillStrokeView: UIView {

    private(set) var fill: UIImageView!
    private(set) var stroke: UIImageView!

    override var contentMode: UIView.ContentMode {
        get { stroke.contentMode }
        set {
            fill.contentMode = newValue
            stroke.contentMode = newValue
        }
    }

    init() {
        super.init(frame: .zero)

        fill = UIImageView()
        addSubview(fill)
        fill.snp.makeConstraints { $0.edges.equalToSuperview() }

        stroke = UIImageView()
        addSubview(stroke)
        stroke.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
