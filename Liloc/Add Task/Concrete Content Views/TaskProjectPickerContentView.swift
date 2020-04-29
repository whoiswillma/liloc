//
//  TaskProjectPickerContentView.swift
//  Liloc
//
//  Created by William Ma on 4/2/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class TaskProjectPickerContentView: TaskPickerContentView {

    let imageTextView: TaskImageTextView

    private let projects: [TodoistProject]

    var didSelectProject: ((Int) -> Void)?

    init(projects: [TodoistProject]) {
        self.projects = projects

        imageTextView = TaskImageTextView(
            fillImage: UIImage(named: "ProjectFill"),
            strokeImage: UIImage(named: "ProjectStroke"),
            placeholder: "project")

        super.init(topView: self.imageTextView)

        pickerView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvailableItems(_ indexSet: Set<Int>, animated: Bool) {
        var sortedIndexes = indexSet.sorted()
        if !sortedIndexes.isEmpty {
            let firstIndex = sortedIndexes.removeFirst()
            let firstProject = TaskPickerView.Item(
                project: projects[firstIndex],
                highlighted: true,
                sourceIndex: firstIndex)

            let availableProjects = sortedIndexes
                .map { TaskPickerView.Item(project: projects[$0], highlighted: false, sourceIndex: $0) }

            pickerView.setItems(
                [firstProject] + availableProjects,
                animated: animated)

        } else {
            pickerView.setItems([], animated: animated)
        }
    }

}

extension TaskProjectPickerContentView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 32) / 2, height: 44)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        let item = pickerView.diffableDataSource
            .snapshot().itemIdentifiers(inSection: nil)[indexPath.row]
        didSelectProject?(item.sourceIndex)
    }

}

extension TaskPickerView.Item {

    init(project: TodoistProject, highlighted: Bool, sourceIndex: Int) {
        let color = UIColor(todoistId: project.color)
        self.init(
            highlighted: highlighted,
            fillImage: UIImage(named: "ProjectStroke"),
            fillTintColor: color,
            strokeImage: UIImage(named: "ProjectFill"),
            strokeTintColor: color.darken(),
            title: project.name ?? "",
            sourceIndex: sourceIndex)
    }

}
