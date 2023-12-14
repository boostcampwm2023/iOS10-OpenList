//
//  TitleHeaderView.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import UIKit

final class TitleHeaderView: UIView {
	enum LayoutConstant {
		static let horizontalPadding: CGFloat = 20
	}
	
	// MARK: - Properties
	private let titleLabel: UILabel = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension TitleHeaderView {
	func configure(title: String) {
		titleLabel.text = title
	}
}

private extension TitleHeaderView {
	func setViewAttributes() {
		backgroundColor = .background
		setTitleLabelAttributes()
	}
	
	func setTitleLabelAttributes() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .extra)
	}
	
	func setViewHierarchies() {
		addSubview(titleLabel)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstant.horizontalPadding),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstant.horizontalPadding)
		])
	}
}
