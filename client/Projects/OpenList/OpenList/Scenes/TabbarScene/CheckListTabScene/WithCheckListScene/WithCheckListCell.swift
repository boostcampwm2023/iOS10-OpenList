//
//  WithCheckListCell.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import UIKit

final class WithCheckListCell: UICollectionViewCell {
	private let cellContentInset: UIEdgeInsets = .init(top: 12, left: 20, bottom: 12, right: 20)
	private let containerView: UIView = .init()
	private let titleLabel: UILabel = .init()
	private let profileImagesOverlapedView: UIStackView = .init()
	private let profileImagesCountLabel: UILabel = .init()
	private var profileImages: [UIImage] = []
	
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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		profileImagesOverlapedView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}
	
	func configure(with item: WithCheckList) {
		titleLabel.text = item.title
		profileImagesCountLabel.text = "\(item.users.count)명과 함께"
	}
}

private extension WithCheckListCell {
	enum LayoutConstant {
		static let cellPadding: UIEdgeInsets = .init(top: 12, left: 20, bottom: 12, right: 20)
		static let bottomMargin: CGFloat = 24
		static let horizontalMargin: CGFloat = 20
		static let containerViewCornerRadius: CGFloat = 8
		static let shadowBlur: CGFloat = 6
		static let shadowAlpha: Float = 0.3
		static let shadowYAxis: CGFloat = 3
		static let contentInsets: UIEdgeInsets = .init(top: 14, left: 10, bottom: 14, right: 10)
		static let spacing: CGFloat = 4
		static let profileImageSize: CGSize = .init(width: 20, height: 20)
		static let overlapWidth: CGFloat = 6
	}
	
	func setViewAttributes() {
		setLayerViewConstraints()
		setContainerViewAttributes()
		setTitleLabelAttributes()
		setProfileImagesOverlapedViewAttributes()
		setProfileImagesCountLabelAttributes()
	}
	
	func setLayerViewConstraints() {
		layer.masksToBounds = false
		layer.shadowPath = UIBezierPath(
			roundedRect: .init(
				origin: .init(x: LayoutConstant.cellPadding.left, y: LayoutConstant.cellPadding.top),
				size: .init(
					width: frame.width - LayoutConstant.cellPadding.left * 2,
					height: 48
				)
			),
			cornerRadius: LayoutConstant.containerViewCornerRadius
		).cgPath
		layer.shadowColor = UIColor.shadow1.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 6
	}
	
	func setContainerViewAttributes() {
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .white
		containerView.layer.masksToBounds = true
		containerView.layer.cornerRadius = LayoutConstant.containerViewCornerRadius
	}
	
	func setTitleLabelAttributes() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .black
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .small)
	}
	
	func setProfileImagesOverlapedViewAttributes() {
		profileImagesOverlapedView.translatesAutoresizingMaskIntoConstraints = false
		profileImagesOverlapedView.alignment = .center
		profileImagesOverlapedView.distribution = .fillProportionally
		profileImagesOverlapedView.spacing = -6
	}
	
	func setProfileImagesCountLabelAttributes() {
		profileImagesCountLabel.translatesAutoresizingMaskIntoConstraints = false
		profileImagesCountLabel.textColor = .gray3
		profileImagesCountLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
	}
	
	func setViewHierarchies() {
		containerView.addSubview(profileImagesOverlapedView)
		containerView.addSubview(profileImagesCountLabel)
		containerView.addSubview(titleLabel)
		contentView.addSubview(containerView)
	}
	
	func setViewConstraints() {
		setContainerViewConstraints()
		setTitleLabelConstraints()
		setProfileImagesOverlapedViewConstraints()
		setProfileImagesCountLabelConstraints()
	}
	
	func setContainerViewConstraints() {
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(
				equalTo: contentView.topAnchor,
				constant: LayoutConstant.cellPadding.top
			),
			containerView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -LayoutConstant.cellPadding.bottom
			),
			containerView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: LayoutConstant.cellPadding.left
			),
			containerView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.cellPadding.right
			)
		])
	}
	
	func setTitleLabelConstraints() {
		NSLayoutConstraint.activate([
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
		titleLabel.setContentHuggingPriority(UILayoutPriority(500), for: .horizontal)
	}
	
	func setProfileImagesOverlapedViewConstraints() {
		NSLayoutConstraint.activate([
			profileImagesOverlapedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			profileImagesOverlapedView.leadingAnchor.constraint(
				greaterThanOrEqualTo: titleLabel.trailingAnchor,
				constant: LayoutConstant.spacing
			),
			profileImagesOverlapedView.trailingAnchor.constraint(
				equalTo: profileImagesCountLabel.leadingAnchor,
				constant: -LayoutConstant.spacing
			),
			profileImagesOverlapedView.topAnchor.constraint(
				equalTo: containerView.topAnchor,
				constant: LayoutConstant.contentInsets.top
			),
			profileImagesOverlapedView.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: -LayoutConstant.contentInsets.bottom
			)
		])
		profileImagesOverlapedView.setContentHuggingPriority(UILayoutPriority(750), for: .horizontal)
	}
	
	func setProfileImagesCountLabelConstraints() {
		NSLayoutConstraint.activate([
			profileImagesCountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			profileImagesCountLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -LayoutConstant.contentInsets.right
			),
			profileImagesCountLabel.topAnchor.constraint(
				equalTo: containerView.topAnchor,
				constant: LayoutConstant.contentInsets.top
			),
			profileImagesCountLabel.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: -LayoutConstant.contentInsets.bottom
			)
		])
	}
}
