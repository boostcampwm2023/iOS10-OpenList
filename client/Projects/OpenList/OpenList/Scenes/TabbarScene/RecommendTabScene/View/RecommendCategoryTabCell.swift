//
//  RecommendCategoryTabCell.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

final class RecommendCategoryTabCell: UICollectionViewCell {
	// MARK: - Properties
	private let titleLabel: UILabel = .init()
	
	override var isSelected: Bool {
		didSet {
			updateTitleLabelColor()
		}
	}
	
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
	
	func configure(title: String) {
		titleLabel.text = title
	}
}

private extension RecommendCategoryTabCell {
	enum LayoutConstant {
		static let titleLableHorizontalPadding: CGFloat = 8
	}
	func setViewAttributes() {
		titleLabel.textColor = .gray3
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		contentView.addSubview(titleLabel)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: LayoutConstant.titleLableHorizontalPadding
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.titleLableHorizontalPadding
			),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	private func updateTitleLabelColor() {
		titleLabel.textColor = isSelected ? .primary1 : .gray3
	}
}
