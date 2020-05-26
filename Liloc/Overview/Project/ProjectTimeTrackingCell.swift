//
//  ProjectTimeTrackingCell.swift
//  Liloc
//
//  Created by William Ma on 5/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class ProjectTimeTrackingCell: UITableViewCell {

    private var stackView: UIStackView!

    private(set) var hoursLoggedView: HoursLoggedView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill

        hoursLoggedView = HoursLoggedView()
        stackView.addArrangedSubview(hoursLoggedView)

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
