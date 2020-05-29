//
//  RootController.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log
import SwiftyUserDefaults
import UIKit

class RootController: LLContainerController<UIViewController> {
    
    private var todoistAPI: TodoistAPI?
    private var togglAPI: TogglAPI?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let todoistCredentials = try! KeychainAPI.todoist.fetch(),
            let togglCredentials = try! KeychainAPI.toggl.fetch(),
            let dao = AppDelegate.shared.dao {
            let todoist = TodoistAPI(dao: dao, token: todoistCredentials)
            let toggl = TogglAPI(
                dao: dao,
                username: togglCredentials.account,
                password: togglCredentials.password)
            
            toggl.sync { error in
                if let error = error {
                    os_log(.error, "Error syncing with toggl: %@", error.localizedDescription)
                }
            }
//            child =
//                DropdownController(
//                    background: OverviewRootController(
//                        dao: dao,
//                        todoist: todoist))
            child = OverviewRootController(dao: dao, todoist: todoist, toggl: toggl)
        } else {
            present(OnboardingNavigationController(), animated: true)
        }
    }

}

extension RootController {

    private func setUpView() {
        view.tintColor = UIColor(named: "LilocBlue")
    }

}
