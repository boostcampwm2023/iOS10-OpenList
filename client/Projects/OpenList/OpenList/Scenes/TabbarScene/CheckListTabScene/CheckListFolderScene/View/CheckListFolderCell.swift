//
//  CheckListFolderCell.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

struct CheckListFolderItem: Hashable {
	var id = UUID()
	var categoryTitle: String
	var saveCount: Int
}

final class CheckListFolderCell: UICollectionViewCell {
	// MARK: Properties
	private let titleLabel: UILabel = .init()
	// 그라디언트 쉐도우가 있는 하얀색 배경의 뷰
	private let folderView: UIView = .init()
	// 폴더에 담길 이미지
	private let folderImageView: UIImageView = .init()
	private let descriptionLabel: UILabel = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// 폴더의 데이터를 넣는 메서드
	func configure(with item: CheckListFolderItem) {
		titleLabel.text = item.categoryTitle
		descriptionLabel.text = "\(item.saveCount)개 저장됨"
	}
}

private extension CheckListFolderCell {
	enum LayoutConstant {
		static let folderViewCornerRadius: CGFloat = 10
		static let folderViewShadowBlur: CGFloat = 6
		static let folderViewContentInsets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
		static let spacing: CGFloat = 10
	}
	
	func setViewAttributes() {
		setTitleLabelAttributes()
		setFolderViewAttributes()
		setFolderImageViewAttributes()
		setDiscriptionLabelAttributes()
	}
	
	func setTitleLabelAttributes() {
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.textColor = .label
		titleLabel.textAlignment = .left
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setFolderImageViewAttributes() {
		folderImageView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setDiscriptionLabelAttributes() {
		descriptionLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .small)
		descriptionLabel.textColor = .gray3
		descriptionLabel.textAlignment = .left
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setFolderViewAttributes() {
		folderView.translatesAutoresizingMaskIntoConstraints = false
		folderView.backgroundColor = .background
		folderView.layer.cornerRadius = LayoutConstant.folderViewCornerRadius
		folderView.layer.applySketchShadow(color: UIColor.shadow1.cgColor, blur: LayoutConstant.folderViewShadowBlur)
	}
	
	func setViewHierarchies() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		contentView.addSubview(folderView)
		folderView.addSubview(folderImageView)
	}
	
	func setViewConstraints() {
		let folderSize = (UIScreen.main.bounds.width - 50) * 0.5
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			folderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConstant.spacing),
			folderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			folderView.widthAnchor.constraint(equalToConstant: folderSize),
			folderView.heightAnchor.constraint(equalToConstant: folderSize),
			
			folderImageView.topAnchor.constraint(
				equalTo: folderView.topAnchor,
				constant: LayoutConstant.folderViewContentInsets.top
			),
			folderImageView.leadingAnchor.constraint(
				equalTo: folderView.leadingAnchor,
				constant: LayoutConstant.folderViewContentInsets.left
			),
			folderImageView.trailingAnchor.constraint(
				equalTo: folderView.trailingAnchor,
				constant: -LayoutConstant.folderViewContentInsets.right
			),
			folderImageView.bottomAnchor.constraint(
				equalTo: folderView.bottomAnchor,
				constant: -LayoutConstant.folderViewContentInsets.bottom
			),
			
			descriptionLabel.topAnchor.constraint(equalTo: folderView.bottomAnchor, constant: LayoutConstant.spacing),
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
}
