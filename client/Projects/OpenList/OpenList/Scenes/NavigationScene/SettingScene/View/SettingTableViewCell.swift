//
//  SettingTableViewCell.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import UIKit

final class SettingTableViewCell: UITableViewCell {
	enum LayoutConstant {
		static let horizontalPadding: CGFloat = 20
	}
	
	// MARK: - Properties
	private let titleLabel: UILabel = .init()
	
	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SettingTableViewCell {
	func configure(with item: SettingItem, accessoryView: UIView? = nil) {
		titleLabel.text = item.title
		self.accessoryView = accessoryView
	}
}

private extension SettingTableViewCell {
	func setViewAttributes() {
		backgroundColor = .background
		setTitleLabelAttributes()
	}
	
	func setTitleLabelAttributes() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .medium)
	}
	
	func setViewHierarchies() {
		contentView.addSubview(titleLabel)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: LayoutConstant.horizontalPadding
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			)
		])
	}
}
