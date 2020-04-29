//
//  ProjectHeaderView.swift
//  Liloc
//
//  Created by William Ma on 4/24/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class ProjectHeaderView: UIView {

    private(set) var navigationBar: UINavigationBar!

    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!

    var didPressBackButton: (() -> Void)?

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

    init() {
        super.init(frame: .zero)

        backgroundColor = .systemBackground

        navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = false
        navigationBar.delegate = self
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true

        titleLabel = UILabel()
        titleLabel.font = UIFont
            .preferredFont(forTextStyle: .largeTitle)
            .with(traits: [.traitBold])

        subtitleLabel = UILabel()
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel

        addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(8)
        }
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

}

extension ProjectHeaderView: UINavigationBarDelegate {

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        didPressBackButton?()
        return false
    }

}
