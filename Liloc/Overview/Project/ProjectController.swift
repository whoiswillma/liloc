//
//  ProjectController.swift
//  Liloc
//
//  Created by William Ma on 4/24/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import UIKit

class ProjectController: UIViewController {

    private enum Section: Hashable, Comparable {

        static func < (lhs: ProjectController.Section, rhs: ProjectController.Section) -> Bool {
            lhs.order < rhs.order
        }

        case timeTracking
        case noDueDay
        case dueDay(RFC3339Day)

        private var order: Int {
            switch self {
            case .timeTracking: return 0
            case .noDueDay: return 1
            case .dueDay: return 2
            }
        }

    }

    private enum Item: Hashable {
        case timeTrackingNotLinked
        case timeTrackingLinked(togglProjectName: String, hoursThisWeek: Int)
        case task(task:TodoistTask, content: String, dueDate: String?)
    }

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        RelativeDateTimeFormatter()
    }()

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMMd",
            options: 0,
            locale: .autoupdatingCurrent)
        return dateFormatter
    }()

    private let todoist: TodoistAPI
    private let project: TodoistProject

    init(todoist: TodoistAPI, project: TodoistProject) {
        self.todoist = todoist
        self.project = project

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var tasksFRC: NSFetchedResultsController<TodoistTask>?

    private var headerView: ProjectHeaderView!

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!

    private let referenceDate = Date()

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
        switch item {
        case let .timeTrackingLinked(togglProjectName, hoursThisWeek):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "timeTracking", for: indexPath)
                as! ProjectTimeTrackingCell

            cell.linkedTogglProjectView.delegate = self
            cell.linkedTogglProjectView.textLabel.text = togglProjectName

            cell.hoursLoggedView.textLabel.text = "\(hoursThisWeek) hr"
            cell.hoursLoggedView.isDisabled = false

            return cell

        case .timeTrackingNotLinked:
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "timeTracking", for: indexPath)
                as! ProjectTimeTrackingCell

            cell.linkedTogglProjectView.delegate = self
            cell.linkedTogglProjectView.textLabel.text = "Link Toggl"

            cell.hoursLoggedView.textLabel.text = "-- hr"
            cell.hoursLoggedView.isDisabled = true

            return cell

        case let .task(task: task, content: content, dueDate: dueDate):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "task", for: indexPath)
                as! TaskCell

            cell.contentLabel.text = content
            cell.leftSubtitleLabel.text = dueDate

            cell.isCompleted = false
            cell.didPressComplete = {
                cell.isCompleted = true

                self.todoist.closeTask(id: task.id) { error in
                    if let error = error {
                        debugPrint(error)
                        fatalError()
                    }
                }
            }

            return cell
        }
    }

    private func performFetch(animated: Bool) {
        updateSortDescriptors()
        try! tasksFRC?.performFetch()
        updateSnapshot(animated: animated)
    }

    private func updateSortDescriptors() {
        tasksFRC?.fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \TodoistTask.dateAdded,
                ascending: true)]
    }

    private func updateSnapshot(animated: Bool) {
        let tasks = tasksFRC?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        var sectionToItems: [Section: Set<Item>] = [:]

        if let togglProject = project.togglProject {
            sectionToItems[.timeTracking] = [.timeTrackingLinked(
                togglProjectName: togglProject.name ?? "unknown name",
                hoursThisWeek: 15)]
        } else {
            sectionToItems[.timeTracking] = [.timeTrackingNotLinked]
        }

        for task in tasks {
            let section: Section = task.dueDate?.rfcDay.map { .dueDay($0) } ?? .noDueDay
            let item: Item = .task(
                task: task,
                content: task.content ?? "",
                dueDate: task.dueDate?.string ?? "no due date")
            sectionToItems[section, default: []].insert(item)
        }

        let sectionsAndItems = sectionToItems.sorted {
            $0.key < $1.key
        }.map { (key, value) -> (Section, [Item]) in
            (key, value.sorted { lhs, rhs in
                switch (lhs, rhs) {
                case let (.task(_, lhsContent, _), .task(_, rhsContent, _)):
                    return lhsContent < rhsContent
                default:
                    return true
                }
            })
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

extension ProjectController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animated: true)
    }

}

extension ProjectController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        switch section {
        case .timeTracking:
            return UIView()

        case .noDueDay:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
                as! ProjectTableSectionHeaderView
            let titleString = NSMutableAttributedString()

            titleString.append(
            NSAttributedString(
                string: "No due date",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)]))

            header.label.attributedText = titleString

            return header

        case let .dueDay(day):
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
                as! ProjectTableSectionHeaderView
            let titleString = NSMutableAttributedString()

            let date = day.date

            let absoluteDate = ProjectController.dateFormatter.string(from: date)
            titleString.append(
                NSAttributedString(
                    string: absoluteDate,
                    attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)]))

            titleString.append(
                NSAttributedString(
                    string: ", ",
                    attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]))

            let relativeDate = ProjectController.relativeDateFormatter.localizedString(for: date, relativeTo: referenceDate)
            titleString.append(
                NSAttributedString(
                    string: relativeDate,
                    attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]))

            header.label.attributedText = titleString

            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return 22
        }
    }

}

extension ProjectController: LinkedTogglProjectViewDelegate {

    func didSelectLinkedTogglProjectView(_ view: LinkedTogglProjectView) {
        let picker = LLPickerController(style: .init(showImage: false))
        present(picker, animated: true)
    }

}

extension ProjectController {

    private func setUpTasksFRC() {
        guard let dao = AppDelegate.shared.dao else {
            return
        }

        let request = TodoistTask.fetchRequest() as NSFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoistTask.id, ascending: true)
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
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: cellProvider)
        dataSource.defaultRowAnimation = .fade
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "task")
        tableView.register(ProjectTimeTrackingCell.self, forCellReuseIdentifier: "timeTracking")
        tableView.register(ProjectTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.tableFooterView = UIView()

        view.insertSubview(tableView, belowSubview: headerView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}
