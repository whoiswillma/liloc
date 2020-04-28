//
//  ProjectController.swift
//  Liloc
//
//  Created by William Ma on 4/24/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import UIKit

private struct Section: Hashable {
    let day: RFC3339Day?
}

private struct Item: Hashable {
    let task: Task
    let content: String
    let dueDate: String?
}

private class DataSource: UITableViewDiffableDataSource<Section, Item> {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let day = snapshot().sectionIdentifiers[section].day {
            return DataSource.dateFormatter.string(from: day.date)
        } else {
            return "No Due Date"
        }
    }

}

class ProjectController: UIViewController {

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        RelativeDateTimeFormatter()
    }()

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    private let todoist: TodoistAPI
    private let project: Project

    init(todoist: TodoistAPI, project: Project) {
        self.todoist = todoist
        self.project = project

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var tasksFRC: NSFetchedResultsController<Task>?

    private var headerView: ProjectHeaderView!

    private var tableView: UITableView!
    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTasksFRC()

        setUpView()
        setUpHeaderView()
        setUpTableView()

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
        cell.leftSubtitleLabel.text = item.dueDate

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
    }

    private func updateSortDescriptors() {
        tasksFRC?.fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Task.dateAdded,
                ascending: true)]
    }

    private func updateSnapshot(animated: Bool) {
        let tasks = tasksFRC?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        var sectionToItems: [Section: Set<Item>] = [:]

        for task in tasks {
            let section = Section(day: task.dueDate?.rfcDay)
            let item = Item(
                task: task,
                content: task.content ?? "",
                dueDate: task.dueDate?.string ?? "no due date")
            sectionToItems[section, default: []].insert(item)
        }

        let sectionsAndItems = sectionToItems.sorted {
            switch ($0.key.day, $1.key.day) {
            case (nil, _): return true
            case (_, nil): return false
            case let (.some(lhs), .some(rhs)): return lhs.date < rhs.date
            }
        }.map { (key, value) -> (Section, [Item]) in
            (key, value.sorted { $0.content < $1.content })
        }

        for (section, items) in sectionsAndItems {
            snapshot.appendSections([section])
            snapshot.appendItems(items)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)

        headerView.subtitleLabel.text =
            String.localizedStringWithFormat(
                NSLocalizedString("numberOfTasks", comment: ""),
                tasksFRC?.fetchedObjects?.count ?? 0)
    }

}

extension ProjectController {

    private func setUpTasksFRC() {
        guard let dao = AppDelegate.shared.dao else {
            return
        }

        let request = Task.fetchRequest() as NSFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.id, ascending: true)
        ]
        request.predicate = NSPredicate(format: "project.id == %@", NSNumber(value: project.id))

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
        headerView = ProjectHeaderView()
        headerView.titleLabel.text = project.name
        headerView.backButtonTitle = "Back"

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
        dataSource = DataSource(tableView: tableView, cellProvider: cellProvider)
        dataSource.defaultRowAnimation = .fade
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "task")
        tableView.tableFooterView = UIView()

        view.insertSubview(tableView, belowSubview: headerView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}

extension ProjectController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animated: true)
    }

}

extension ProjectController: UITableViewDelegate {

}
