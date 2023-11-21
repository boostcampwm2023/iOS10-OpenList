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
		case major = "대 카테고리"
		case medium = "중 카테고리"
		case sub = "소 카테고리"
	}

	private let gradationView: UIView = .init(frame: .zero)
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
		gradationView.backgroundColor = UIColor.primary1
		gradationView.translatesAutoresizingMaskIntoConstraints = false
		
		categoryLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .large)
		categoryLabel.textColor = .black
		categoryLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierachies() {
		addSubview(gradationView)
		addSubview(categoryLabel)
	}
	
	func setViewConstraints() {
		let safeArea = safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			gradationView.topAnchor.constraint(equalTo: safeArea.topAnchor),
			gradationView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			gradationView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			gradationView.heightAnchor.constraint(equalToConstant: 100),
			
			categoryLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			categoryLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			categoryLabel.topAnchor.constraint(equalTo: gradationView.bottomAnchor),
			categoryLabel.heightAnchor.constraint(equalToConstant: 24)
		])
	}
}
