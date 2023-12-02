//
//  AddCheckListItemTableViewHeader.swift
//  OpenList
//
//  Created by Hoon on 12/2/23.
//

import UIKit

protocol AddCheckListItemTableViewHeaderDelegate: AnyObject {
	func selectAll()
	func deselectAll()
}

final class AddCheckListItemTableViewHeader: UITableViewHeaderFooterView {
	enum AddCheckListItemTableViewSection {
		case selected
		case unselected
	}
	
	// MARK: - UI Component
	private let sectionLabel: UILabel = .init()
	private let sectionButton: UIButton = .init()
	weak var delegate: AddCheckListItemTableViewHeaderDelegate?
	
	convenience init(
		reuseIdentifier: String?,
		section: AddCheckListItemTableViewSection
	) {
		self.init(reuseIdentifier: reuseIdentifier)
		configure(section: section)
	}
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setAttributes()
		setHeirachies()
		setConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Helper
extension AddCheckListItemTableViewHeader {
	func configure(section: AddCheckListItemTableViewSection) {
		switch section {
		case .selected:
			sectionLabel.text = "선택 항목"
			sectionButton.configureAsUnderlineTextButton(title: "모두 선택해제", color: .primary1)
		case .unselected:
			sectionLabel.text = "추천 목록"
			sectionButton.configureAsUnderlineTextButton(title: "모두 선택", color: .primary1)
		}
	}
}

// MARK: - Button Method
private extension AddCheckListItemTableViewHeader {
	@objc func selectAll() {
		delegate?.selectAll()
	}
	
	@objc func deselectAll() {
		delegate?.deselectAll()
	}
}

// MARK: - UI Configure
private extension AddCheckListItemTableViewHeader {
	enum LayoutConstant {
		static let horizontalPadding: CGFloat = 20
		static let componentHeight: CGFloat = 18
	}
	
	func setAttributes() {
		sectionLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		sectionLabel.textColor = .gray2
		sectionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		sectionButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setHeirachies() {
		contentView.addSubview(sectionLabel)
		contentView.addSubview(sectionButton)
	}
	
	func setConstraints() {
		NSLayoutConstraint.activate([
			sectionLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: LayoutConstant.horizontalPadding
			),
			sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			sectionLabel.heightAnchor.constraint(equalToConstant: LayoutConstant.componentHeight),
			
			sectionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
			sectionButton.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			sectionButton.heightAnchor.constraint(equalToConstant: LayoutConstant.componentHeight)
		])
	}
}
