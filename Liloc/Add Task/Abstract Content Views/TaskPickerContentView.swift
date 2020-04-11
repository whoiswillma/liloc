//
//  TaskPickerContentView.swift
//  Liloc
//
//  Created by William Ma on 3/31/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class TaskPickerContentView: TaskContentView {

    private(set) var flowLayout: UICollectionViewFlowLayout!
    private(set) var pickerView: TaskPickerView!

    init(topView: UIView) {
        super.init(frame: .zero)

        let bottomContainer = UIView()
        bottomContainer.clipsToBounds = true

        flowLayout = UICollectionViewFlowLayout()
        pickerView = TaskPickerView(frame: .zero, collectionViewLayout: flowLayout)
        pickerView.backgroundColor = .systemBackground

        addSubview(topView)
        addSubview(bottomContainer)
        bottomContainer.addSubview(pickerView)

        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        pickerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        collapsedLayout.append(contentsOf: bottomContainer.snp.prepareConstraints { make in
            make.height.equalTo(0)
        })

        expandedLayout.append(contentsOf: bottomContainer.snp.prepareConstraints { make in
            make.height.equalTo(pickerView)
        })

        setExpanded(false, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

