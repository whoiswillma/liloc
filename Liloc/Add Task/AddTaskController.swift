//
//  AddTaskController.swift
//  Liloc
//
//  Created by William Ma on 3/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftUI
import UIKit

class AddTaskController: LLContainerController<UIHostingController<AddTaskView>> {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpChild()
    }
    
}

extension AddTaskController {

    func setUpView() {
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
    }

    func setUpChild() {
        child = UIHostingController(rootView: AddTaskView(controller: self))
    }

}
