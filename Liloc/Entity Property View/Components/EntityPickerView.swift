//
//  TaskPickerView.swift
//  Liloc
//
//  Created by William Ma on 4/3/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

class EntityPickerView: UICollectionView {

    struct Item: Hashable {
        let highlighted: Bool
        let fillImage: UIImage?
        let fillTintColor: UIColor?
        let strokeImage: UIImage?
        let strokeTintColor: UIColor?
        let title: String

        let sourceIndex: Int
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    private(set) var diffableDataSource: UICollectionViewDiffableDataSource<Never?, Item>!

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        register(PickerCell.self , forCellWithReuseIdentifier: "cell")

        diffableDataSource = .init(
            collectionView: self,
            cellProvider: cellProvider)
        dataSource = diffableDataSource

        isScrollEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setItems(_ items: [Item], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Never?, Item>()
        snapshot.appendSections([nil])
        snapshot.appendItems(items)
        diffableDataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func cellProvider(_ collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath) as! PickerCell

        cell.strokeImageView.image = item.strokeImage
        cell.strokeImageView.tintColor = item.strokeTintColor
        cell.fillImageView.image = item.fillImage
        cell.fillImageView.tintColor = item.fillTintColor
        cell.titleLabel.text = item.title

        cell.contentView.backgroundColor = item.highlighted
            ? UIColor.systemGray.withAlphaComponent(0.1)
            : nil

        return cell
    }

}

private class PickerCell: UICollectionViewCell {

    private(set) var fillImageView: UIImageView!
    private(set) var strokeImageView: UIImageView!
    private(set) var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor.systemGray3.cgColor

        fillImageView = UIImageView()
        strokeImageView = UIImageView()
        titleLabel = UILabel()

        contentView.addSubview(fillImageView)
        fillImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
            make.width.equalTo(fillImageView.snp.height)
        }

        contentView.addSubview(strokeImageView)
        strokeImageView.snp.makeConstraints { make in
            make.edges.equalTo(fillImageView)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(strokeImageView.snp.trailing).offset(12)
            make.top.trailing.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
