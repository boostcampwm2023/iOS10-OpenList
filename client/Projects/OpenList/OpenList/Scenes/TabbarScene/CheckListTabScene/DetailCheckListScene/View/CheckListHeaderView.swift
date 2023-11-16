//
//  CheckListHeaderView.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import UIKit

final class CheckListHeaderView: UIView {
	private enum LayoutConstant {
		static let spacing: CGFloat = 8
		static let lockImageSize: CGSize = .init(width: 24, height: 24)
	}
	// MARK: - Properties
	private let titleLabel: UILabel = .init()
	private let lockImageView: UIImageView = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension CheckListHeaderView {
	func configure(title: String, isLocked: Bool) {
		backgroundColor = UIColor.background
		titleLabel.text = title
		lockImageView.image = isLocked ?
		UIImage(systemName: "lock")?.withTintColor(.label, renderingMode: .alwaysOriginal) :
		UIImage(systemName: "lock.open")?.withTintColor(.label, renderingMode: .alwaysOriginal)
	}
}

private extension CheckListHeaderView {
	func setViewAttributes() {
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.textColor = .label
		titleLabel.numberOfLines = 2
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		lockImageView.image = UIImage(systemName: "lock")
		lockImageView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		addSubview(titleLabel)
		addSubview(lockImageView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			lockImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.lockImageSize.width),
			lockImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.lockImageSize.height),
			lockImageView.leadingAnchor.constraint(
				equalTo: titleLabel.trailingAnchor,
				constant: LayoutConstant.spacing
			),
			lockImageView.topAnchor.constraint(equalTo: topAnchor),
			lockImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}
}
