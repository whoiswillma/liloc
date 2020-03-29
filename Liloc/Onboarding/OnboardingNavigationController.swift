//
//  OnboardingNavigationController.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class OnboardingNavigationController: UINavigationController {

    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [OnboardingController()]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isModalInPresentation = true

        view.tintColor = UIColor(named: "LilocBlue")

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

}

extension OnboardingNavigationController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        setNavigationBarHidden(viewController is OnboardingController, animated: animated)
    }

}
