//
//  LLContainerController.swift
//  Liloc
//
//  Created by William Ma on 3/23/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class LLContainerController<Child: UIViewController>: UIViewController {

    var child: Child! {
        willSet {
            if let child = child {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
        didSet {
            addChild(child)
            view.addSubview(child.view)
            child.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            child.didMove(toParent: self)

            childControllerDidChange()
        }
    }

    func childControllerDidChange() {
    }

}
