//
//  CategoryHeaderView.swift
//  OpenList
//
//  Created by Hoon on 11/22/23.
//

import UIKit

final class CategoryHeaderView: UICollectionReusableView {
	// MARK: - Properties
	static let identifier = "CategoryHeaderView"
	
	enum Category: String {
		case main = "대 카테고리"
		case sub = "중 카테고리"
		case minor = "소 카테고리"
	}

	private let categoryLabel: UILabel = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierachies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(_ category: Category) {
		categoryLabel.text = category.rawValue
	}
}

private extension CategoryHeaderView {
	func setViewAttributes() {
		categoryLabel.font = .notoSansCJKkr(type: .medium, size: .large)
		categoryLabel.textColor = .gray1
		categoryLabel.translatesAutoresizingMaskIntoConstraints = false
	}

	func setViewHierachies() {
		addSubview(categoryLabel)
	}
	
	func setViewConstraints() {
		let safeArea = safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			categoryLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			categoryLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			categoryLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
			categoryLabel.heightAnchor.constraint(equalToConstant: 24)
		])
	}
}
