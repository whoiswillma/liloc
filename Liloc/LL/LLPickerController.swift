//
//  LLPickerController.swift
//  Liloc
//
//  Created by William Ma on 5/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

protocol LLPickerControllerDelegate: AnyObject {

    func pickerController(
        _ pickerController: LLPickerController,
        didSelectItems items: [LLPickerController.Item])

}

class LLPickerController: UIViewController {

    struct Style {
        let title: String
        let showImages: Bool
        let showSections: Bool
    }

    struct Item: Hashable {
        let item: AnyHashable

        let image: UIImage?
        let title: String
        let subtitle: String
    }

    let style: Style
    let sectionToItems: [(String, [Item])]

    private var navigation: UINavigationController!
    private var content: LLPickerContentController!

    weak var delegate: LLPickerControllerDelegate?

    init(style: Style, sectionToItems: [(String, [Item])]) {
        self.style = style
        self.sectionToItems = sectionToItems

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        content = LLPickerContentController(pickerController: self)
        navigation = UINavigationController(rootViewController: content)
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        navigation.didMove(toParent: self)
    }

}

private class LLPickerContentController: UIViewController {

    private weak var pickerController: LLPickerController!

    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<String, LLPickerController.Item>!

    private var presentedItems: [(String, [LLPickerController.Item])]

    init(pickerController: LLPickerController) {
        self.pickerController = pickerController

        self.presentedItems = pickerController.sectionToItems

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchBar()
        setUpTableView()

        updateSnapshot(animated: true)
    }

    private func updateSnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<String, LLPickerController.Item>()

        for (section, items) in presentedItems {
            snapshot.appendSections([section])
            snapshot.appendItems(items)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func cellProvider(
        _ tableView: UITableView,
        indexPath: IndexPath,
        item: LLPickerController.Item
    ) -> UITableViewCell {
        if pickerController.style.showImages {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "imageTitleSubtitle", for: indexPath)
                as! LLImageTitleSubtitleCell

            cell.fillImageView.image = item.image
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.subtitle

            return cell
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "titleSubtitle", for: indexPath)
                as! LLTitleSubtitleCell

            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.subtitle

            return cell
        }
    }

    @objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

}

extension LLPickerContentController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = presentedItems[indexPath.section].1[indexPath.row]
        pickerController.delegate?.pickerController(pickerController, didSelectItems: [item])
    }

}

extension LLPickerContentController {

    func setUpSearchBar() {
        navigationItem.title = pickerController.style.title

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonPressed(_:)))

        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
    }

    func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(LLTitleSubtitleCell.self, forCellReuseIdentifier: "titleSubtitle")
        tableView.register(LLImageTitleSubtitleCell.self, forCellReuseIdentifier: "imageTitleSubtitle")
        tableView.delegate = self
        dataSource = .init(tableView: tableView, cellProvider: cellProvider)
        tableView.dataSource = dataSource
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
