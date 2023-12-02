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
	private var profileImageViews: [UIImageView] = .init()
	
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
		profileImageViews.forEach { $0.cancelLoadImage() }
		profileImagesOverlapedView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}
	
	func configure(with item: WithCheckList) {
		titleLabel.text = item.title
		profileImagesCountLabel.text = "+\(item.users.count)"
		let profileImageUrls = Array(item.users.compactMap(\.profileImage).prefix(3))
		profileImageViews = makeProfileImagesView(with: profileImageUrls)
		addReverseArrangedSubview(profileImageViews)
	}
}

private extension WithCheckListCell {
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
		contentView.layer.applySketchShadow(
			color: UIColor.shadow1.cgColor,
			blur: LayoutConstant.shadowBlur,
			alpha: LayoutConstant.shadowAlpha,
			y: LayoutConstant.shadowYAxis
		)
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
		titleLabel.backgroundColor = .green
	}
	
	func setProfileImagesOverlapedViewAttributes() {
		profileImagesOverlapedView.translatesAutoresizingMaskIntoConstraints = false
		profileImagesOverlapedView.alignment = .center
		profileImagesOverlapedView.distribution = .fillProportionally
		profileImagesOverlapedView.spacing = -6
		profileImagesOverlapedView.backgroundColor = .red
	}
	
	func setProfileImagesCountLabelAttributes() {
		profileImagesCountLabel.translatesAutoresizingMaskIntoConstraints = false
		profileImagesCountLabel.textColor = .gray3
		profileImagesCountLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		profileImagesCountLabel.backgroundColor = .blue
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
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
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
		titleLabel.setContentCompressionResistancePriority(UILayoutPriority(500), for: .horizontal)
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
			)
		])
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
		profileImagesCountLabel.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
	}
}

private extension WithCheckListCell {
	func makeProfileImagesView(with profileImages: [String]) -> [UIImageView] {
		profileImages.map { profileImage in
			let imageView = UIImageView()
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.widthAnchor.constraint(equalToConstant: LayoutConstant.profileImageSize.width).isActive = true
			imageView.heightAnchor.constraint(equalToConstant: LayoutConstant.profileImageSize.height).isActive = true
			imageView.contentMode = .scaleAspectFill
			imageView.layer.masksToBounds = true
			imageView.layer.borderWidth = 1
			imageView.layer.borderColor = UIColor.white.cgColor
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = LayoutConstant.profileImageSize.width / 2
			imageView.loadImage(urlString: profileImage)
			return imageView
		}
	}
	
	func addReverseArrangedSubview(_ subViews: [UIView]) {
		subViews.forEach { profileImagesOverlapedView.addArrangedSubview($0) }
		profileImagesOverlapedView.arrangedSubviews.forEach { profileImagesOverlapedView.sendSubviewToBack($0) }
	}
}
