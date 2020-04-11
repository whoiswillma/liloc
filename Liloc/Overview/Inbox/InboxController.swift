//
//  InboxController.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import DateTools
import Hero
import UIKit

class InboxController: UIViewController {

    enum Hero {
        static let imageViewID = "InboxController.headerView.imageView"
        static let titleLabelID = "InboxController.headerView.titleLabel"
        static let subtitleLabelID = "InboxController.headerView.subtitleLabel"
    }

    private enum SortOptions: CaseIterable, CustomStringConvertible {
        case dateAdded
        case content

        var description: String {
            switch self {
            case .dateAdded: return "Date Added"
            case .content: return "Alphabetical"
            }
        }
    }

    private struct Item: Hashable {

        private static let dateAddedFormatter = RelativeDateTimeFormatter()

        let content: String
        let relativeDateAdded: String

        let task: Task

        init(task: Task, referenceDate: Date) {
            self.content = task.content ?? ""

            if let dateAdded = task.dateAdded {
                self.relativeDateAdded = Item.dateAddedFormatter
                    .localizedString(for: dateAdded, relativeTo: referenceDate)
            } else {
                self.relativeDateAdded = "unknown"
            }

            self.task = task
        }
    }

    private let dao: CoreDataDAO
    private let todoist: TodoistAPI

    init(dao: CoreDataDAO, todoist: TodoistAPI) {
        self.dao = dao
        self.todoist = todoist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var tasksFRC: NSFetchedResultsController<Task>?

    private var headerView: HeaderView!

    private var sortOptionsView: SortOptionsView<SortOptions>!

    private var shadowView: ShadowView!

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Never?, Item>!

    private let referenceDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTasksFRC()

        setUpView()
        setUpHeaderView()
        setUpSortOptionsView()
        setUpTableView()
        setUpShadowView()
        setUpHero()

        performFetch(animated: false)
    }

    private func cellProvider(
        _ tableView: UITableView,
        indexPath: IndexPath,
        item: Item
    ) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "task", for: indexPath)
            as! TaskCell

        cell.contentLabel.text = item.content
        cell.leftSubtitleLabel.text = item.relativeDateAdded

        cell.isCompleted = false
        cell.didPressComplete = {
            cell.isCompleted = true
            
            self.todoist.closeTask(id: item.task.id) { error in
                if let error = error {
                    debugPrint(error)
                    fatalError()
                }
            }
        }

        return cell
    }

    private func performFetch(animated: Bool) {
        updateSortDescriptors()
        try! tasksFRC?.performFetch()
        updateSnapshot(animated: animated)

        headerView.subtitleLabel.text =
            String.localizedStringWithFormat(
                NSLocalizedString("numberOfTasks", comment: ""),
                tasksFRC?.fetchedObjects?.count ?? 0)
    }

    private func updateSnapshot(animated: Bool) {
        let tasks = tasksFRC?.fetchedObjects ?? []
        let sortedTasks = tasks.sorted {
            switch ($0.dateAdded, $1.dateAdded) {
            case (.none, _): return true
            case (_, .none): return false
            case let (.some(lhs), .some(rhs)): return lhs < rhs
            }
        }

        let now = Date()

        var snapshot = NSDiffableDataSourceSnapshot<Never?, Item>()
        snapshot.appendSections([nil])
        snapshot.appendItems(sortedTasks.map { Item(task: $0, referenceDate: now) })
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    @objc private func sortOptionsChanged() {
        performFetch(animated: false)
    }

    @objc private func updateSortDescriptors() {
        let sortDescriptor: NSSortDescriptor
        switch sortOptionsView.selectedOption {
        case .dateAdded:
            sortDescriptor = NSSortDescriptor(
                keyPath: \Task.dateAdded,
                ascending: true)
        case .content:
            sortDescriptor = NSSortDescriptor(
                keyPath: \Task.content,
                ascending: true)
        }

        tasksFRC?.fetchRequest.sortDescriptors = [sortDescriptor]
    }

    @objc private func refreshControlDidRefresh(_ sender: UIRefreshControl) {
        todoist.sync(full: false) { error in
            if let error = error {
                debugPrint(error)
                fatalError()
            }

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                sender.endRefreshing()
            }
        }
    }

}

extension InboxController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animated: true)
    }

}

extension InboxController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.shadowManager.shadowMask =
            scrollView.contentOffset.y < 1 ? [] : [.bottom]
    }

}

extension InboxController {

    private func setUpTasksFRC() {
        guard let dao = AppDelegate.shared.dao else {
            return
        }

        let request = Task.fetchRequest() as NSFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.id, ascending: true)
        ]
        request.predicate = NSPredicate(format: "project.inboxProject == YES")

        tasksFRC = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dao.moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        tasksFRC?.delegate = self
    }

    private func setUpView() {
        view.backgroundColor = .systemBackground
    }

    private func setUpHeaderView() {
        headerView = HeaderView(
            image: UIImage(named: "InboxStroke")!,
            title: "Inbox",
            subtitle: "No tasks",
            backButtonTitle: "Back"
        )

        headerView.didPressBackButton = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setUpSortOptionsView() {
        sortOptionsView = SortOptionsView()
        sortOptionsView.addTarget(
            self,
            action: #selector(sortOptionsChanged),
            for: .valueChanged)

        view.addSubview(sortOptionsView)
        sortOptionsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: cellProvider
        )
        dataSource.defaultRowAnimation = .fade
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "task")
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshControlDidRefresh(_:)),
            for: .valueChanged)
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortOptionsView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setUpShadowView() {
        shadowView = ShadowView()
        shadowView.shadowManager.setDefaultShadowProperties()
        shadowView.shadowManager.shadowMask = []
        view.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.bottom.equalTo(tableView.snp.top)
            make.leading.trailing.equalTo(tableView)
            make.height.equalTo(1)
        }
    }

    private func setUpHero() {
        hero.isEnabled = true

        headerView.imageView.hero.id = Hero.imageViewID
        headerView.titleLabel.hero.id = Hero.titleLabelID
        headerView.subtitleLabel.hero.id = Hero.subtitleLabelID
    }

}
