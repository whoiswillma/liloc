//
//  LLDropdownController.swift
//  Liloc
//
//  Created by William Ma on 3/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log

import UIKit

class LLDropdownController: UIViewController {

    private enum Const {
        static let animationDuration = 0.75
    }

    private let background: UIViewController

    private var darkenView: UIView!

    private(set) var dropdown: UIViewController?

    init(background: UIViewController) {
        self.background = background

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpBackground()
        setUpDarkenView()
    }

    func presentDropdown(_ dropdown: UIViewController, animated: Bool) {
        guard self.dropdown == nil else {
            os_log(.error, "%@ called while a dropdown is already being presented", #function)
            return
        }

        addDropdown(dropdown)

        if animated {
            dropdown.view.transform =
                CGAffineTransform(
                    translationX: 0,
                    y: -dropdown.view.frame.height)

            darkenView.alpha = 0

            UIViewPropertyAnimator(
                duration: Const.animationDuration,
                dampingRatio: 1)
            {
                self.setPresentProperties()
            }.startAnimation()
        } else {
            setPresentProperties()
        }
    }

    private func addDropdown(_ dropdown: UIViewController) {
        self.dropdown = dropdown

        addChild(dropdown)
        view.addSubview(dropdown.view)
        dropdown.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        dropdown.didMove(toParent: self)
    }

    private func setPresentProperties() {
        dropdown?.view.transform = .identity
        darkenView.alpha = 1
        darkenView.isUserInteractionEnabled = true
    }

    func dismissDropdown(animated: Bool) {
        guard let dropdown = dropdown else {
            os_log(.error, "%@ called when no dropdown is presented", #function)
            return
        }

        if animated {
            let animator = UIViewPropertyAnimator(
                duration: Const.animationDuration,
                dampingRatio: 1)
            {
                dropdown.view.transform =
                    CGAffineTransform(
                        translationX: 0,
                        y: -dropdown.view.frame.height)

                self.setDismissProperties()
            }

            animator.addCompletion { _ in
                self.removeDropdown(dropdown)
            }

            animator.startAnimation()
        } else {
            setDismissProperties()
            removeDropdown(dropdown)
        }
    }

    private func removeDropdown(_ dropdown: UIViewController) {
        dropdown.willMove(toParent: nil)
        dropdown.view.removeFromSuperview()
        dropdown.removeFromParent()

        self.dropdown = nil
    }

    private func setDismissProperties() {
        darkenView.alpha = 0
        darkenView.isUserInteractionEnabled = false
    }

    @objc private func darkenViewTapped(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            dismissDropdown(animated: true)
        }
    }

}

extension LLDropdownController {

    private func setUpBackground() {
        addChild(background)
        view.addSubview(background.view)
        background.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        background.didMove(toParent: self)
    }

    private func setUpDarkenView() {
        darkenView = UIView()
        darkenView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        darkenView.alpha = 0
        darkenView.isUserInteractionEnabled = false

        let tapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(darkenViewTapped(_:)))
        darkenView.addGestureRecognizer(tapGestureRecognizer)

        view.addSubview(darkenView)
        view.bringSubviewToFront(darkenView)
        darkenView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

}

extension UIViewController {

    var dropdownController: LLDropdownController? {
        var controller = parent
        while controller != nil, !(controller is LLDropdownController) {
            controller = controller?.parent
        }
        return controller as? LLDropdownController
    }

}
