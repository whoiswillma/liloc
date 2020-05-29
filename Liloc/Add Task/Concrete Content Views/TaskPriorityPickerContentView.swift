//
//  TaskPriorityPickerContentView.swift
//  Liloc
//
//  Created by William Ma on 4/2/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit
import os.log

class TaskPriorityPickerContentView: TaskPickerContentView {

    let imageTextView: TaskImageTextView

    var didSelectPriority: ((TodoistPriority) -> Void)?

    init() {
        self.imageTextView = TaskImageTextView(
            fillImage: UIImage(named: "FlagFill"),
            strokeImage: UIImage(named: "FlagStroke"),
            placeholder: "priority")

        super.init(topView: self.imageTextView)

        pickerView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        setUpSnapshot()
    }

    func setUpSnapshot() {
        pickerView.setItems(
            TodoistPriority.allCases.enumerated().map {
                .init(priority: $0.element, sourceIndex: $0.offset)
            },
            animated: false)
    }

}

extension TaskPriorityPickerContentView: UICollectionViewDelegateFlowLayout {

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
        let availableWidth = max(0, collectionView.frame.width - 8 - 8 - 8 - 8 - 8 - 8)
        return CGSize(width: availableWidth / 4, height: 44)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        guard let priority = TodoistPriority(displayPriority: indexPath.row + 1) else {
            os_log("Unable to construct priority from number: %d", indexPath.row + 1)
            return
        }
        didSelectPriority?(priority)
    }

}

extension TaskPickerView.Item {

    init(priority: TodoistPriority, sourceIndex: Int) {
        self.init(
            highlighted: false,
            fillImage: UIImage(named: "FlagFill"),
            fillTintColor: priority.color?.lighten(),
            strokeImage: UIImage(named: "FlagStroke"),
            strokeTintColor: priority.color,
            title: priority.shortDescription,
            sourceIndex: sourceIndex)
    }

}
