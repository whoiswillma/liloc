//
//  OverviewRootController.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Combine
import UIKit

class OverviewRootController: UIViewController {

    private enum FocusState {
        case off
        case on(uiUpdateTimer: Timer, start: Date)
    }

    private static let updateTimerDuration: TimeInterval = 5

    private let dao: CoreDataDAO
    private let todoist: TodoistAPI
    private let toggl: TogglAPI

    private var navigation: UINavigationController!

    private var pillView: PillView!
    private var focusState: FocusState = .off

    private var togglRefreshTimer: Timer?

    private var cancellables: Set<AnyCancellable> = []

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
        setUpCurrentTimeEntry()
    }

    @objc private func addTaskButtonPressed(_ sender: UIButton) {
        let controller = try! AddTaskController(dao: dao, todoist: todoist)
        present(controller, animated: true)
    }

    @objc private func focusButtonPressed(_ sender: UIButton) {
        let controller = FocusRootController(todoist: todoist, toggl: toggl)
        present(controller, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navigation.additionalSafeAreaInsets
            = UIEdgeInsets(top: 0, left: 0, bottom: pillView.frame.height + 16, right: 0)
    }

    private func updateFocusButtonText(start: Date?) {
        if let start = start {
            let minutes = Int(Date().timeIntervalSince(start) / 60)
            UIView.performWithoutAnimation {
                self.pillView.rightButton.setImage(UIImage(named: "FocusOn"), for: .normal)
                self.pillView.rightButton.setTitle("\(minutes) m", for: .normal)
                self.pillView.rightButton.layoutIfNeeded()
            }
        } else {
            self.pillView.rightButton.setImage(UIImage(named: "FocusOff"), for: .normal)
            self.pillView.rightButton.setTitle("-- m", for: .normal)
        }
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
            OverviewController(dao: dao, todoist: todoist, toggl: toggl, delegate: self))
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

        pillView.rightButton.setImage(UIImage(named: "FocusOff"), for: .normal)
        pillView.rightButton.setTitle("-- m", for: .normal)
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

    private func setUpCurrentTimeEntry() {
        toggl.startAutoupdateTimer()
        toggl.currentTimeEntry.sink { timeEntry in
            switch timeEntry {
            case let .active(description: _, project: _, start: start, tags: _):
                self.updateFocusButtonText(start: start)

                let updateTimer = Timer(timeInterval: OverviewRootController.updateTimerDuration, repeats: true) { timer in
                    switch self.focusState {
                    case let .on(uiUpdateTimer: uiUpdateTimer, start: start) where uiUpdateTimer == timer:
                        self.updateFocusButtonText(start: start)
                    default:
                        timer.invalidate()
                    }
                }

                // allow the update timer to run even while scrolling / doing other things
                RunLoop.main.add(updateTimer, forMode: .common)

                self.focusState = .on(uiUpdateTimer: updateTimer, start: start)

            case .inactive:
                self.updateFocusButtonText(start: nil)
                self.focusState = .off
            }
        }.store(in: &cancellables)
    }

}
