//
//  ProjectController.swift
//  Liloc
//
//  Created by William Ma on 4/24/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import os.log

import CoreData
import UIKit

class ProjectController: UIViewController {

    private enum CellId: String {
        case toggl
        case stats
        case task
    }

    private enum Section: Hashable {
        case toggl
        case noDueDay
        case dueDay(RFC3339Day)
    }

    private struct Stats: Hashable {
        let minutesToday: Int
    }

    private enum Item: Hashable {
        case togglProject(linkedProjectName: String?)
        case timeTracking(Stats?)
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

    private let dao: CoreDataDAO
    private let todoist: TodoistAPI
    private let toggl: TogglAPI

    private let project: TodoistProject

    init(dao: CoreDataDAO, todoist: TodoistAPI, toggl: TogglAPI, project: TodoistProject) {
        self.dao = dao
        self.todoist = todoist
        self.toggl = toggl

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
        case .togglProject(linkedProjectName: .none):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellId.toggl.rawValue, for: indexPath)
                as! ProjectTogglCell

            cell.delegate = self

            cell.projectLinkButton.setTitle("link project", for: .normal)
            cell.entriesButton.isEnabled = false

            return cell

        case let .togglProject(linkedProjectName: .some(projectName)):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellId.toggl.rawValue, for: indexPath)
                as! ProjectTogglCell

            cell.delegate = self

            cell.projectLinkButton.setTitle(projectName, for: .normal)
            cell.entriesButton.isEnabled = true

            return cell

        case .timeTracking(.none):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellId.stats.rawValue, for: indexPath)
                as! ProjectStatsCell

            cell.hoursLoggedView.textLabel.text = "--m"
            cell.hoursLoggedView.isDisabled = true

            return cell

        case let .timeTracking(.some(stats)):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellId.stats.rawValue, for: indexPath)
                as! ProjectStatsCell

            cell.hoursLoggedView.textLabel.text = "\(stats.minutesToday)m"
            cell.hoursLoggedView.isDisabled = false

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

            cell.priority = TodoistPriority(rawValue: task.priority)

            return cell
        }
    }

    private func performFetch(animated: Bool) {
        updateSortDescriptors()
        try! tasksFRC?.performFetch()
        updateSnapshot(animated: animated)

        if let togglProject = project.togglProject {
            toggl.syncReports(togglProject, referenceDate: referenceDate) { [weak self] error in
                if let error = error {
                    os_log(.error, "Error while syncing toggl report: %@", error.localizedDescription)
                }

                self?.updateSnapshot(animated: animated)
            }
        }
    }

    private func updateSortDescriptors() {
        tasksFRC?.fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \TodoistTask.dateAdded,
                ascending: true)]
    }

    private func updateSnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        addTogglSection(&snapshot)
        addTaskSections(&snapshot)

        dataSource.apply(snapshot, animatingDifferences: animated)

        headerView.subtitleLabel.text =
            String.localizedStringWithFormat(
                NSLocalizedString("numberOfTasks", comment: ""),
                tasksFRC?.fetchedObjects?.count ?? 0)
    }

    private func addTogglSection(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
        if let togglProject = project.togglProject {

            let minutesToday: Int
            if let reportReference = togglProject.report?.referenceDate,
                reportReference.sameDay(as: referenceDate) {

                let milliseconds = Int(togglProject.report?.timeToday ?? 0)
                minutesToday = milliseconds / 1000 / 60
            } else {
                minutesToday = 0
            }

            let stats = Stats(minutesToday: minutesToday)
            snapshot.appendSections([.toggl])
            snapshot.appendItems([
                .togglProject(linkedProjectName: togglProject.name ?? "unknown name"),
                .timeTracking(stats)
            ])
        } else {
            snapshot.appendSections([.toggl])
            snapshot.appendItems([
                .togglProject(linkedProjectName: nil),
                .timeTracking(nil)
            ])
        }
    }

    private func addTaskSections(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
        let tasks = tasksFRC?.fetchedObjects ?? []

        var dayToTasks: [RFC3339Day?: Set<TodoistTask>] = [:]
        for task in tasks {
            dayToTasks[task.dueDate?.rfcDay, default: []].insert(task)
        }

        let sortedDayToTasks: [(RFC3339Day?, [TodoistTask])] = dayToTasks.sorted {
            $0.key?.date ?< $1.key?.date
        }.map { (day, tasks) -> (RFC3339Day?, [TodoistTask]) in
            (day, tasks.sorted { lhs, rhs in
                lhs.content ?< rhs.content
            })
        }

        for (day, tasks) in sortedDayToTasks {
            snapshot.appendSections([day.map(Section.dueDay) ?? .noDueDay])
            snapshot.appendItems(tasks.map { task in
                .task(
                    task: task,
                    content: task.content ?? "",
                    dueDate: task.dueDate?.string ?? "no due date")
            })
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        switch section {
        case .toggl:
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

extension ProjectController: ProjectTogglCellDelegate {

    func projectLinkButtonPressed(on cell: ProjectTogglCell) {
        let togglProjects = (try? dao.fetchAll(TogglProject.self)) ?? []
        let items = togglProjects.map { project in
            LLPickerController.Item(
                item: project,
                image: nil,
                title: project.name ?? "unknown name",
                subtitle: project.todoistProject.map { $0.name ?? "unknown todoist name" } ?? "unlinked")
        }

        let picker = LLPickerController(
            style: .init(title: "Choose Toggl Project", showImages: false, showSections: false),
            sectionToItems: [("", items)])
        picker.delegate = self
        present(picker, animated: true)
    }

    func entriesButtonPressed(on cell: ProjectTogglCell) {
        fatalError()
    }

}

extension ProjectController: LLPickerControllerDelegate {

    func pickerController(_ pickerController: LLPickerController, didSelectItems items: [LLPickerController.Item]) {
        guard let item = items.first, let togglProject = item.item as? TogglProject else {
            return
        }

        let linkTogglProject = {
            self.project.togglProject = togglProject
            try! self.dao.saveContext()
            self.updateSnapshot(animated: false)

            pickerController.dismiss(animated: true)
        }

        if togglProject.todoistProject != nil, togglProject.todoistProject !== project {
            let togglProjectName = togglProject.name ?? "\"\""
            let oldProjectName = togglProject.todoistProject?.name ?? "\"\""
            let newProjectName = project.name ?? "\"\""

            let alertController = UIAlertController(
                title: "Unlink from \(oldProjectName)",
                message: "Are you sure you want to unlink \(togglProjectName) from \(oldProjectName), and instead link it to \(newProjectName)",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                linkTogglProject()
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            pickerController.present(alertController, animated: true)
        } else {
            linkTogglProject()
        }
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

        view.tintColor = UIColor(todoistId: project.color).darken()
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
        tableView.register(TaskCell.self, forCellReuseIdentifier: CellId.task.rawValue)
        tableView.register(ProjectStatsCell.self, forCellReuseIdentifier: CellId.stats.rawValue)
        tableView.register(ProjectTogglCell.self, forCellReuseIdentifier: CellId.toggl.rawValue)
        tableView.register(ProjectTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()

        view.insertSubview(tableView, belowSubview: headerView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}
