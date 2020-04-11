//
//  TaskContentView.swift
//  Liloc
//
//  Created by William Ma on 3/31/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SnapKit
import UIKit

class TaskContentView: UIView {

    private(set) var isExpanded = false

    var collapsedLayout: [Constraint] = []
    var expandedLayout: [Constraint] = []

    func setExpanded(_ expanded: Bool, animated: Bool) {
        self.isExpanded = expanded

        let actions: () -> Void = {
            if expanded {
                self.collapsedLayout.forEach { $0.deactivate() }
                self.expandedLayout.forEach { $0.activate() }
            } else {
                self.expandedLayout.forEach { $0.deactivate() }
                self.collapsedLayout.forEach { $0.activate() }
            }

            expanded ? self.willExpand() : self.willCollapse()

            self.layoutScrollView()
        }

        if animated {
            UIViewPropertyAnimator(duration: 0.35, dampingRatio: 1) {
                actions()
            }.startAnimation()
        } else {
            actions()
        }
    }

    private func layoutScrollView() {
        var scrollView = superview
        while scrollView != nil, !(scrollView is UIScrollView) {
            scrollView = scrollView?.superview
        }
        scrollView?.layoutIfNeeded()
    }

    func willExpand() {
    }

    func willCollapse() {
    }

}
