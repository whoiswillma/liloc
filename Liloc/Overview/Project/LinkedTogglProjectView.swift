//
//  LinkedTogglProjectView.swift
//  Liloc
//
//  Created by William Ma on 5/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

protocol LinkedTogglProjectViewDelegate: AnyObject {

    func didSelectLinkedTogglProjectView(_ view: LinkedTogglProjectView)

}

class LinkedTogglProjectView: UIView {

    private(set) var imageView: UIImageView!
    private(set) var textLabel: UILabel!
    private var pressGestureRecognizer: UILongPressGestureRecognizer!

    weak var delegate: LinkedTogglProjectViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(image: UIImage(systemName: "link.circle"))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.width.height.equalTo(30)
        }

        textLabel = UILabel()
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.textAlignment = .center
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(2)
            make.bottom.leading.trailing.equalToSuperview().inset(8)
        }

        pressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressGestureRecognizer))
        pressGestureRecognizer.minimumPressDuration = 0
        addGestureRecognizer(pressGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func longPressGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }

        case .ended:
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
            }

            delegate?.didSelectLinkedTogglProjectView(self)

        default:
            break
        }
    }

}
