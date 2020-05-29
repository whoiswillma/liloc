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

    private enum SortOption: CaseIterable, CustomStringConvertible {
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
        let task: TodoistTask
        let priority: TodoistPriority
        let content: String
        let relativeDateAdded: String
    }

    private static let dateAddedFormatter = RelativeDateTimeFormatter()

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

    private var tasksFRC: NSFetchedResultsController<TodoistTask>?
    private var sortOption: SortOption = .dateAdded {
        didSet { performFetch(animated: false) }
    }

    private var headerView: InboxHeaderView!

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Never?, Item>!

    private let referenceDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTasksFRC()

        setUpView()
        setUpHeaderView()
        setUpTableView()
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

        cell.priority = item.priority

        return cell
    }

    private func performFetch(animated: Bool) {
        updateSortDescriptors()
        try! tasksFRC?.performFetch()
        updateSnapshot(animated: animated)
    }

    private func updateSortDescriptors() {
        let sortDescriptor: NSSortDescriptor
        switch sortOption {
        case .dateAdded:
            sortDescriptor = NSSortDescriptor(
                keyPath: \TodoistTask.dateAdded,
                ascending: true)
        case .content:
            sortDescriptor = NSSortDescriptor(
                key: "content",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare(_:)))
        }

        tasksFRC?.fetchRequest.sortDescriptors = [sortDescriptor]
    }

    private func updateSnapshot(animated: Bool) {
        let tasks = tasksFRC?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Never?, Item>()
        snapshot.appendSections([nil])
        snapshot.appendItems(tasks.map {
            Item(
                task: $0,
                priority: TodoistPriority(rawValue: $0.priority) ?? .four,
                content: $0.content ?? "",
                relativeDateAdded: InboxController.dateAddedFormatter.string(for: $0.dateAdded) ?? "unknown") })
        dataSource.apply(snapshot, animatingDifferences: animated)

        headerView.subtitleLabel.text =
        String.localizedStringWithFormat(
            NSLocalizedString("numberOfTasks", comment: ""),
            tasksFRC?.fetchedObjects?.count ?? 0)
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

    @objc private func sortButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Text", style: .default) { _ in
            self.sortOption = .content
        })
        alertController.addAction(UIAlertAction(title: "Date Added", style: .default) { _ in
            self.sortOption = .dateAdded
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
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
        headerView.shadow.shadowMask =
            scrollView.contentOffset.y < 1 ? [] : [.bottom]
    }

}

extension InboxController {

    private func setUpTasksFRC() {
        guard let dao = AppDelegate.shared.dao else {
            return
        }

        let request = TodoistTask.fetchRequest() as NSFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoistTask.id, ascending: true)
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
        headerView = InboxHeaderView(
            image: UIImage(named: "InboxStroke")!,
            title: "Inbox",
            subtitle: "No tasks")
        headerView.backButtonTitle = "Back"
        headerView.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                style: .plain,
                target: self,
                action: #selector(sortButtonPressed))]

        headerView.shadow.shadowMask = []

        headerView.didPressBackButton = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.trailing.equalToSuperview()
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

        view.insertSubview(tableView, belowSubview: headerView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setUpHero() {
        hero.isEnabled = true

        headerView.imageView.hero.id = Hero.imageViewID
        headerView.titleLabel.hero.id = Hero.titleLabelID
        headerView.subtitleLabel.hero.id = Hero.subtitleLabelID
    }

}
