//
//  SharedCheckListCell.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

struct SharedCheckListItem: Hashable {
	var id = UUID()
	var title: String
}

final class SharedCheckListCell: UICollectionViewCell {
	private let cellContentInset: UIEdgeInsets = .init(top: 12, left: 20, bottom: 12, right: 20)
	private let containerView: UIView = .init()
	private let titleLabel: UILabel = .init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configure(with item: SharedCheckListItem) {
		titleLabel.text = item.title
	}
}

private extension SharedCheckListCell {
	enum LayoutConstant {
		static let cellPadding: UIEdgeInsets = .init(top: 0, left: 20, bottom: 24, right: 20)
		static let bottomMargin: CGFloat = 24
		static let horizontalMargin: CGFloat = 20
		static let containerViewCornerRadius: CGFloat = 8
		static let shadowBlur: CGFloat = 6
		static let shadowAlpha: Float = 0.3
		static let shadowYAxis: CGFloat = 3
		static let contentInsets: UIEdgeInsets = .init(top: 14, left: 10, bottom: 14, right: 10)
		static let spacing: CGFloat = 4
	}
	
	func setViewAttributes() {
		setContainerViewAttributes()
		setTitleLabelAttributes()
	}
	
	func setContainerViewAttributes() {
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .background
		containerView.layer.cornerRadius = LayoutConstant.containerViewCornerRadius
		containerView.layer.applySketchShadow(
			color: UIColor.shadow1.cgColor,
			blur: LayoutConstant.shadowBlur,
			alpha: LayoutConstant.shadowAlpha,
			y: LayoutConstant.shadowYAxis
		)
	}
	
	func setTitleLabelAttributes() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .gray1
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .small)
	}
	
	func setViewHierarchies() {
		containerView.addSubview(titleLabel)
		contentView.addSubview(containerView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: LayoutConstant.contentInsets.left
			),
			titleLabel.topAnchor.constraint(
				equalTo: containerView.topAnchor,
				constant: LayoutConstant.contentInsets.top
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: -LayoutConstant.contentInsets.bottom
			)
		])
	}
}
