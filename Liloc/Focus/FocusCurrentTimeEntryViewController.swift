//
//  FocusCurrentTimeEntryViewController.swift
//  Liloc
//
//  Created by William Ma on 6/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class FocusCurrentTimeEntryViewController: UIViewController {

    private var scrollView: UIScrollView!
    private var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpStackView()
    }

}

extension FocusCurrentTimeEntryViewController {

    private func setUpScrollView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setUpStackView() {
        stackView = UIStackView()

        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = 16

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(20)
            make.width.equalToSuperview().offset(-40)
        }
    }

}
