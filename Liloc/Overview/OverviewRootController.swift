//
//  OverviewRootController.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class OverviewRootController: UIViewController {

    private let dao: CoreDataDAO
    private let todoist: TodoistAPI
    private let toggl: TogglAPI

    private var navigation: UINavigationController!

    private var pillView: PillView!

    init(dao: CoreDataDAO, todoist: TodoistAPI, toggl: TogglAPI) {
        self.dao = dao
        self.todoist = todoist
        self.toggl = toggl

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigation()
        setUpPillView()
    }

    @objc private func addTaskButtonPressed(_ sender: UIButton) {
        let controller = try! AddTaskController(dao: dao, todoist: todoist)
        present(controller, animated: true)
    }

    @objc private func focusButtonPressed(_ sender: UIButton) {

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navigation.additionalSafeAreaInsets
            = UIEdgeInsets(top: 0, left: 0, bottom: pillView.frame.height + 16, right: 0)
    }

}

extension OverviewRootController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool) {

        let duration = viewController.transitionCoordinator?.transitionDuration ?? 0
        if animated {
            UIView.animate(withDuration: duration / 2) {
                self.pillView.tintColor = viewController.view.tintColor
            }
        }

        viewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { context in
            UIView.animate(withDuration: duration) {
                self.pillView.tintColor = self.navigation.viewControllers.last?.view.tintColor
            }
        })
    }

}

extension OverviewRootController {

    private func setUpNavigation() {
        navigation = UINavigationController(rootViewController:
            OverviewController(dao: dao, todoist: todoist, toggl: toggl))
        navigation.delegate = self

        navigation.interactivePopGestureRecognizer?.delegate = nil

        navigation.setNavigationBarHidden(true, animated: false)

        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        navigation.didMove(toParent: self)
    }

    private func setUpPillView() {
        pillView = PillView()

        pillView.leftButton.setImage(UIImage(named: "Plus"), for: .normal)
        pillView.leftButton.setTitle("Add Task", for: .normal)
        pillView.leftButton.addTarget(
            self,
            action: #selector(addTaskButtonPressed(_:)),
            for: .touchUpInside)

        pillView.rightButton.setImage(UIImage(named: "FocusOn"), for: .normal)
        pillView.rightButton.setTitle("Focus", for: .normal)
        pillView.rightButton.addTarget(
            self,
            action: #selector(focusButtonPressed(_:)),
            for: .touchUpInside)

        view.addSubview(pillView)
        pillView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(36)
            make.bottom.equalTo(view.snp.bottomMargin).inset(8)
        }
    }

}
