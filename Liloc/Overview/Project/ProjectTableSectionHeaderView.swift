//
//  ProjectTableSectionHeaderView.swift
//  Liloc
//
//  Created by William Ma on 4/28/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class ProjectTableSectionHeaderView: UITableViewHeaderFooterView {

    private(set) var label: UILabel!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundView = UIView()
        backgroundView?.backgroundColor = .systemBackground

        label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
