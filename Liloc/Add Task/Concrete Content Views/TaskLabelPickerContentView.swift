//
//  TaskLabelPickerContentView.swift
//  Liloc
//
//  Created by William Ma on 4/4/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit
import os.log

class TaskLabelPickerContentView: TaskPickerContentView {

    let imageTokenView: TaskImageTokenView

    private let labels: [TodoistLabel]

    var didSelectLabel: ((Int) -> Void)?

    init(labels: [TodoistLabel]) {
        self.labels = labels

        imageTokenView = TaskImageTokenView(
            fillImage: nil,
            strokeImage: UIImage(named: "TagStroke"),
            placeholder: "labels")

        super.init(topView: imageTokenView)

        pickerView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAvailableItems(_ indexSet: Set<Int>, animated: Bool) {
        let items = indexSet.sorted().map {
            TaskPickerView.Item(label: labels[$0], sourceIndex: $0)
        }
        pickerView.setItems(items, animated: animated)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        imageTokenView.tokenField.tokenBackgroundColor = tintColor
    }

}

extension TaskLabelPickerContentView: UICollectionViewDelegateFlowLayout {

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
        return 8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = max(0, collectionView.frame.width - 8 - 8 - 8)
        return CGSize(width: availableWidth / 2, height: 44)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        let item = pickerView.diffableDataSource
            .snapshot().itemIdentifiers(inSection: nil)[indexPath.row]
        didSelectLabel?(item.sourceIndex)
    }

}

extension TaskPickerView.Item {

    init(label: TodoistLabel, sourceIndex: Int) {
        self.init(
            highlighted: false,
            fillImage: UIImage(named: "TagStroke"),
            fillTintColor: UIColor(todoistId: label.color),
            strokeImage: nil,
            strokeTintColor: nil,
            title: label.name ?? "",
            sourceIndex: sourceIndex)
    }
    
}
