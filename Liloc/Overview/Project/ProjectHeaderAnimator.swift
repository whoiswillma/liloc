//
//  ProjectHeaderAnimator.swift
//  Liloc
//
//  Created by William Ma on 5/30/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CRRefresh
import UIKit

class ProjectHeaderAnimator: UIView, CRRefreshProtocol {

    var view: UIView { return self }
    var insets: UIEdgeInsets = .zero
    var trigger: CGFloat = 66
    var execute: CGFloat = 66
    var endDelay: CGFloat = 0
    var hold: CGFloat = 66

    var titleLabel: UILabel!
    private var indicatorView: UIActivityIndicatorView!

    public override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = "Pull to refresh"
        addSubview(titleLabel)

        indicatorView = UIActivityIndicatorView.init(style: .medium)
        indicatorView.isHidden = true
        addSubview(indicatorView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }

        indicatorView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(22)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-8)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshBegin(view: CRRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        titleLabel.text = "Loading"
    }

    func refreshEnd(view: CRRefreshComponent, finish: Bool) {
        if finish {
            indicatorView.stopAnimating()
            indicatorView.isHidden = true
        } else {
            titleLabel.text = "Pull to refresh"
        }
    }

    func refreshWillEnd(view: CRRefreshComponent) {

    }

    func refresh(view: CRRefreshComponent, progressDidChange progress: CGFloat) {

    }

    func refresh(view: CRRefreshComponent, stateDidChange state: CRRefreshState) {
        switch state {
        case .refreshing:
            titleLabel.text = "Loading"

        case .pulling:
            titleLabel.text = "Release to refresh"

        case .idle:
            titleLabel.text = "Pull to refresh"

        default:
            break
        }
    }

}
