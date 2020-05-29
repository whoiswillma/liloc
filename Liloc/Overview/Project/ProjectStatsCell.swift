//
//  ProjectStatsCell.swift
//  Liloc
//
//  Created by William Ma on 5/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class ProjectStatsCell: UITableViewCell {

    private var roundedRectView: UIView!
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!

    private(set) var hoursLoggedView: HoursLoggedView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        roundedRectView = UIView()
        roundedRectView.clipsToBounds = true
        roundedRectView.layer.cornerRadius = 16
        roundedRectView.backgroundColor = .systemGroupedBackground
        roundedRectView.layer.cornerCurve = .continuous

        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill

        hoursLoggedView = HoursLoggedView()
        stackView.addArrangedSubview(hoursLoggedView)

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }

        roundedRectView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(roundedRectView)
        roundedRectView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        hoursLoggedView.snp.makeConstraints { make in
            make.width.equalTo(contentView).dividedBy(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
