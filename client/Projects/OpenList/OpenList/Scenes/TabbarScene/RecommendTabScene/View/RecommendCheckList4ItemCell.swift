//
//  RecommendCheckList4ItemCell.swift
//  OpenList
//
//  Created by 김영균 on 12/5/23.
//

import UIKit

/// 체크리스트 4개가 한번에 담겨있는 셀
final class RecommendCheckList4ItemCell: UICollectionViewCell {
	private let stackView: UIStackView = .init()
	private var recommendCheckListItemView: [UIView] = []
	
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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		recommendCheckListItemView = []
	}
	
	func configure(with items: [CheckListItem]) {
		recommendCheckListItemView = items.map(makeCheckList(with:))
		recommendCheckListItemView.forEach(stackView.addArrangedSubview(_:))
		for _ in 0..<4 - items.count {
			stackView.addArrangedSubview(makeSpacerView())
		}
	}
}

private extension RecommendCheckList4ItemCell {
	func setViewAttributes() {
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.distribution = .fillEqually
		stackView.spacing = 10
	}
	
	func setViewHierarchies() {
		contentView.addSubview(stackView)
	}
	
	func setViewConstraints() {
		stackView.frame = contentView.bounds
	}
}

private extension RecommendCheckList4ItemCell {
	func makeCheckList(with item: CheckListItem) -> UIView {
		let view = UIStackView()
		view.axis = .horizontal
		view.alignment = .leading
		view.spacing = 8
		let checkListIconView = makeCheckListIconView(isChecked: item.isChecked)
		let titleLabel = makeTitleLabel(with: item.title)
		view.addArrangedSubview(checkListIconView)
		view.addArrangedSubview(titleLabel)
		return view
	}
	
	func makeCheckListIconView(isChecked: Bool) -> UIImageView {
		let checkImage = isChecked ? UIImage.checkCircle : UIImage.circle
		let resizedCheckImage = checkImage.resizeImage(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysTemplate)
		let checkListIconView = UIImageView(frame: .init(origin: .zero, size: .init(width: 20, height: 20)))
		checkListIconView.image = resizedCheckImage
		checkListIconView.tintColor = .primary1
		checkListIconView.translatesAutoresizingMaskIntoConstraints = false
		return checkListIconView
	}
	
	func makeTitleLabel(with title: String) -> UILabel {
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.textColor = .label
		titleLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		titleLabel.numberOfLines = 1
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		return titleLabel
	}
	
	func makeSpacerView() -> UIView {
		let spacer = UIView()
		spacer.isUserInteractionEnabled = false
		spacer.frame.size = .init(width: 20, height: 20)
		return spacer
	}
}
