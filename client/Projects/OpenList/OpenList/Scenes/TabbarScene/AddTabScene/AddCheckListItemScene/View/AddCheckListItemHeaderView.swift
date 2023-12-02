//
//  AddCheckListItemHeaderView.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import UIKit

final class AddCheckListItemHeaderView: UIView {
	private enum LayoutConstant {
		static let spacing: CGFloat = 8
		static let lockImageSize: CGSize = .init(width: 24, height: 24)
	}
	// MARK: - Properties
	private let titleLabel: UILabel = .init()
	private let tagLabel: UILabel = .init()
	
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

extension AddCheckListItemHeaderView {
	func configure(title: String, tags: [String]?) {
		backgroundColor = UIColor.background
		titleLabel.text = title
		guard let tags = tags else { return }
		tagLabel.text = tags
			.map { "#\($0)" }
			.joined(separator: " ")
	}
}

private extension AddCheckListItemHeaderView {
	func setViewAttributes() {
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .large)
		titleLabel.textColor = .label
		titleLabel.numberOfLines = 2
		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		tagLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		tagLabel.textColor = .gray1
		tagLabel.numberOfLines = 2
		tagLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		addSubview(titleLabel)
		addSubview(tagLabel)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: tagLabel.topAnchor,
				constant: -LayoutConstant.spacing
			),
			
			tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			tagLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: LayoutConstant.spacing
			)
		])
	}
}
