//
//  OverviewTableHeaderView.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class OverviewTableHeaderView: UIView {

    private(set) var chevron: UIImageView!
    private(set) var titleButton: UIButton!
    private(set) var newButton: UIButton!

    private(set) var shadowManager: LLLayerShadowManager?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemGroupedBackground

        titleButton = UIButton(type: .system)
        titleButton.setTitleColor(.label, for: .normal)
        titleButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        addSubview(titleButton)
        titleButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20).priority(.high)
            make.top.bottom.equalToSuperview().inset(4).priority(.high)
        }

        chevron = UIImageView(image: UIImage(named: "ChevronDown"))
        chevron.contentMode = .scaleAspectFit
        addSubview(chevron)
        chevron.snp.makeConstraints { make in
            make.leading.equalTo(titleButton.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(4).priority(.high)
            make.bottom.lessThanOrEqualToSuperview().inset(4).priority(.high)
            make.width.equalTo(chevron.snp.height)
        }

        newButton = UIButton(type: .system)
        newButton.setImage(UIImage(named: "Plus"), for: .normal)
        addSubview(newButton)
        newButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20).priority(.high)
            make.top.bottom.equalToSuperview().inset(4).priority(.high)
        }

        titleButton.isEnabled = false
        chevron.isHidden = true
        newButton.isHidden = true

        shadowManager = LLLayerShadowManager(layer: layer)
        shadowManager?.setDefaultShadowProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension OverviewTableHeaderView: LLTableViewShadowHeader {

}
