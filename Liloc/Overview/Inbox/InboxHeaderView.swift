//
//  InboxHeaderView.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class InboxHeaderView: UIView {

    private var navigationBar: UINavigationBar!

    private(set) var imageView: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!

    var didPressBackButton: (() -> Void)?

    var shadow: LLLayerShadowManager!

    var backButtonTitle: String = "" {
        didSet {
            setNavigationBarItems()
        }
    }

    var rightBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            setNavigationBarItems()
        }
    }

    init(image: UIImage?, title: String, subtitle: String) {
        super.init(frame: .zero)

        backgroundColor = .systemBackground

        navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = false
        navigationBar.delegate = self
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true

        imageView = UIImageView(image: image)
        imageView?.contentMode = .scaleAspectFit

        titleLabel = UILabel()
        titleLabel.font = UIFont
            .preferredFont(forTextStyle: .largeTitle)
            .with(traits: [.traitBold])
        titleLabel.text = title

        subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel

        addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)

            make.height.equalTo(imageView.snp.width)
        }

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(imageView)
        }

        shadow = LLLayerShadowManager(layer: layer)
        shadow.setDefaultShadowProperties()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setNavigationBarItems() {
        let navigationItem = UINavigationItem(title: "")
        navigationItem.rightBarButtonItems = rightBarButtonItems
        let backNavigationItem = UINavigationItem(title: backButtonTitle)
        navigationBar.items = [backNavigationItem, navigationItem]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadow.layerGeometryDidChange()
    }

}

extension InboxHeaderView: UINavigationBarDelegate {

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        didPressBackButton?()
        return false
    }

}
