//
//  UIViewController.swift
//  Liloc
//
//  Created by William Ma on 3/27/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

extension UIViewController {

    var dropdownController: DropdownController? {
        var controller = parent
        while controller != nil, !(controller is DropdownController) {
            controller = controller?.parent
        }
        return controller as? DropdownController
    }

}
