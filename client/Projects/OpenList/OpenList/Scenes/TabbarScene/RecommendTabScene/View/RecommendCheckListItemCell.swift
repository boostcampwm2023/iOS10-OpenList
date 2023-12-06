//
//  RecommendCheckListItemCell.swift
//  OpenList
//
//  Created by 김영균 on 12/5/23.
//

import UIKit

final class RecommendCheckListItemCell: UICollectionViewCell {
	private let checkListIconView: UIImageView = .init()
	private let titleLabel: UILabel = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		checkListIconView.image = nil
	}
	
	func configure(with item: CheckListItem) {
		titleLabel.text = item.title
		let checkImage = item.isChecked ? UIImage.checkCircle : UIImage.circle
		let imageSize = CGSize(width: 16, height: 16)
		let resizedCheckImage = checkImage.resizeImage(size: imageSize)?.withRenderingMode(.alwaysTemplate)
		checkListIconView.image = resizedCheckImage
	}
}

private extension RecommendCheckListItemCell {
	func setViewAttributes() {
		titleLabel.textColor = .label
		titleLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		titleLabel.numberOfLines = 1
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		checkListIconView.tintColor = .primary1
		checkListIconView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(checkListIconView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checkListIconView.topAnchor.constraint(equalTo: contentView.topAnchor),
			checkListIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			checkListIconView.widthAnchor.constraint(equalToConstant: 20),
			checkListIconView.heightAnchor.constraint(equalToConstant: 20),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: checkListIconView.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
}
