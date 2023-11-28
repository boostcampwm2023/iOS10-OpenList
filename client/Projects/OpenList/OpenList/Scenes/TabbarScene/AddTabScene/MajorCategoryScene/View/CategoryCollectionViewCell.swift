//
//  CategoryCollectionViewCell.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
	// MARK: - Properties
	static let identifier = "CategoryCollectionViewCell"
	private let cateGoryLabel: UILabel = .init(frame: .zero)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setAttributes()
		setViewHierachies()
		setConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var isSelected: Bool {
		didSet {
			layer.borderColor = isSelected ? UIColor.primary1.cgColor : UIColor.gray2.cgColor
			cateGoryLabel.textColor = isSelected ? UIColor.primary1 : UIColor.gray2
		}
	}
	
	func configure(categoryItem: String) {
		cateGoryLabel.text = categoryItem
	}
	
	func getCatergoryName() -> String? {
		return cateGoryLabel.text
	}
}

// MARK: - UI Configure
private extension CategoryCollectionViewCell {
	func setAttributes() {
		cateGoryLabel.translatesAutoresizingMaskIntoConstraints = false
		cateGoryLabel.textColor = UIColor.gray2
		cateGoryLabel.textAlignment = .center
		cateGoryLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .small)
		
		backgroundColor = .background
		layer.borderColor = UIColor.gray2.cgColor
		layer.borderWidth = 1
		layer.cornerRadius = 8
		clipsToBounds = true
	}
	
	func setViewHierachies() {
		contentView.addSubview(cateGoryLabel)
	}
	
	func setConstraints() {
		let safeArea = contentView.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			cateGoryLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			cateGoryLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			cateGoryLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
			cateGoryLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8)
		])
	}
}
