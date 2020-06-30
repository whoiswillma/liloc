//
//  EntityProjectPickerContentView.swift
//  Liloc
//
//  Created by William Ma on 4/2/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class EntityProjectPickerContentView: EntityPickerContentView {

    struct Project {
        let color: UIColor
        let name: String
    }

    let imageTextView: EntityImageTextView

    private let projects: [Project]

    var didSelectProject: ((Int) -> Void)?

    init(projects: [Project]) {
        self.projects = projects

        imageTextView = EntityImageTextView(
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
            let firstProject = EntityPickerView.Item(
                project: projects[firstIndex],
                highlighted: true,
                sourceIndex: firstIndex)

            let availableProjects = sortedIndexes.map {
                EntityPickerView.Item(
                    project: projects[$0],
                    highlighted: false,
                    sourceIndex: $0)
            }

            pickerView.setItems(
                [firstProject] + availableProjects,
                animated: animated)

        } else {
            pickerView.setItems([], animated: animated)
        }
    }

}

extension EntityProjectPickerContentView: UICollectionViewDelegateFlowLayout {

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

private extension EntityPickerView.Item {

    init(project: EntityProjectPickerContentView.Project, highlighted: Bool, sourceIndex: Int) {
        self.init(
            highlighted: highlighted,
            fillImage: UIImage(named: "ProjectStroke"),
            fillTintColor: project.color,
            strokeImage: UIImage(named: "ProjectFill"),
            strokeTintColor: project.color.lighten(),
            title: project.name,
            sourceIndex: sourceIndex)
    }

}
