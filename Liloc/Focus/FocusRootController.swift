//
//  FocusRootController.swift
//  Liloc
//
//  Created by William Ma on 6/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class FocusRootController: UIViewController {

    private let todoist: TodoistAPI
    private let toggl: TogglAPI

    init(todoist: TodoistAPI, toggl: TogglAPI) {
        self.todoist = todoist
        self.toggl = toggl

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
}
