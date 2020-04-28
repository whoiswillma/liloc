//
//  OverviewController.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import CoreData
import Hero
import SwiftUI
import UIKit

class OverviewController: UIViewController, ObservableObject {

    private enum Section: Hashable {
        case topLevel
        case projects
    }

    private enum Item: Hashable {
        case inbox(taskCount: Int)
        case outlook(taskCount: Int)
        case project(id: Int64, name: String, color: Int64, taskCount: Int)
    }

    private let todoist: TodoistAPI
    private let dao: CoreDataDAO

    init(dao: CoreDataDAO, todoist: TodoistAPI) {
        self.dao = dao
        self.todoist = todoist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var projectsFRC: NSFetchedResultsController<Project>?

    private var headerView: UIView!

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private var headerManager: LLTableViewHeaderManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpProjectsFRC()

        setUpView()
        setUpHeaderView()
        setUpTableView()

        syncTodoist()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        performFetch(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        headerManager.layoutHeaders()
    }

    private func updateSnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        let dao = AppDelegate.shared.dao

        snapshot.appendSections([.topLevel])
        snapshot.appendItems([
            .inbox(taskCount: (try? dao?.inboxProject()?.tasks?.count) ?? 0),
            .outlook(taskCount: 0)])

        snapshot.appendSections([.projects])
        let projects = projectsFRC?.fetchedObjects ?? []
        snapshot.appendItems(projects.map { project in
            .project(
                id: project.id, 
                name: project.name ?? "",
                color: project.color,
                taskCount: project.tasks?.count ?? 0)
        })

        dataSource.apply(snapshot, animatingDifferences: animated)

        headerManager.layoutHeaders()
    }

    private func cellProvider(tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell {
        switch item {
        case let .inbox(taskCount):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "topLevel", for: indexPath)
                as! ImageTitleSubtitleCell

            cell.titleLabel.text = "Inbox"
            cell.subtitleLabel.text =
                String.localizedStringWithFormat(
                    NSLocalizedString("numberOfTasks", comment: ""),
                    taskCount)
            cell.strokeImageView.image = UIImage(named: "InboxStroke")
            cell.strokeImageView.tintColor = UIColor(named: "LilocBlue")

            cell.strokeImageView.hero.id = InboxController.Hero.imageViewID
            cell.titleLabel.isOpaque = false
            cell.titleLabel.hero.id = InboxController.Hero.titleLabelID
            cell.subtitleLabel.isOpaque = false
            cell.subtitleLabel.hero.id = InboxController.Hero.subtitleLabelID

            return cell

        case let .outlook(taskCount):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "topLevel", for: indexPath)
                as! ImageTitleSubtitleCell

            cell.titleLabel.text = "Outlook"
            cell.subtitleLabel.text =
                String.localizedStringWithFormat(
                    NSLocalizedString("numberOfTasks", comment: ""),
                    taskCount)
            cell.strokeImageView.image = UIImage(named: "Outlook")
            cell.strokeImageView.tintColor = UIColor(named: "LilocBlue")

            return cell

        case let .project(id, name, color, taskCount):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "project", for: indexPath)
                as! ImageTitleSubtitleCell

            cell.titleLabel.text = name
            cell.subtitleLabel.text =
                String.localizedStringWithFormat(
                    NSLocalizedString("numberOfTasks", comment: ""),
                    taskCount)
            cell.strokeImageView.image = UIImage(named: "ProjectStroke")
            cell.strokeImageView.tintColor = UIColor(todoistId: color)
            cell.fillImageView.image = UIImage(named: "ProjectFill")
            cell.fillImageView.tintColor = UIColor(todoistId: color).darken()

            cell.accessoryType = .disclosureIndicator

            return cell
        }
    }

    private func performFetch(animated: Bool) {
        do {
            try projectsFRC?.performFetch()
            updateSnapshot(animated: animated)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }

    private func syncTodoist() {
        todoist.sync(full: false) { [weak self] error in
            if let error = error {
                debugPrint(error)
                fatalError()
            }

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    @objc private func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
        syncTodoist()
    }

}

extension OverviewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animated: true)
    }

}

extension OverviewController: LLTableViewHeaderManagerDelegate {

    func tableViewHeaderManager(_ manager: LLTableViewHeaderManager, headerForSection section: Int) -> UIView? {
        switch section {
        case 0:
            let headerView = OverviewTableHeaderView()
            headerView.titleButton.setTitle("Front Matter", for: .normal)
            return headerView

        case 1:
            let headerView = OverviewTableHeaderView()
            headerView.titleButton.setTitle("Projects", for: .normal)
            return headerView

        default:
            return nil
        }
    }

}

extension OverviewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerManager.layoutHeaders()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerManager.viewForHeader(inSection: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerManager.heightForHeader(inSection: section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let inbox = InboxController(dao: dao, todoist: todoist)
                navigationController?.pushViewController(inbox, animated: true)

            default:
                break
            }

        case 1:
            if let project = projectsFRC?.fetchedObjects?[indexPath.row] {
                let projectController = ProjectController(todoist: todoist, project: project)
                navigationController?.pushViewController(projectController, animated: true)
            }

        default:
            break
        }
    }

}

extension OverviewController {

    private func setUpProjectsFRC() {
        let request = Project.fetchRequest() as NSFetchRequest<Project>
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        request.predicate = NSPredicate(format: "inboxProject = FALSE")

        projectsFRC = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dao.moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        projectsFRC?.delegate = self
    }

    private func setUpView() {
        view.backgroundColor = .systemGroupedBackground
    }

    private func setUpHeaderView() {
        headerView = UIView()

        let navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true

        let label = UILabel()
        label.text = "Liloc"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).with(traits: [.traitBold])

        headerView.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }

        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    private func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        dataSource = UITableViewDiffableDataSource<Section, Item>(
            tableView: tableView, cellProvider: cellProvider
        )
        dataSource.defaultRowAnimation = .middle
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(ImageTitleSubtitleCell.self, forCellReuseIdentifier: "topLevel")
        tableView.register(ImageTitleSubtitleCell.self, forCellReuseIdentifier: "project")
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(refreshControlDidRefresh(_:)),
            for: .valueChanged)
        tableView.refreshControl = refreshControl

        headerManager = LLTableViewHeaderManager(tableView: tableView, delegate: self)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}
