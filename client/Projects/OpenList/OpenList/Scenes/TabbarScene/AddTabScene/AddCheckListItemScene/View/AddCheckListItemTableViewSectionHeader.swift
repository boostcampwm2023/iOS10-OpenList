//
//  AddCheckListItemTableViewSectionHeader.swift
//  OpenList
//
//  Created by Hoon on 12/2/23.
//

import UIKit

protocol AddCheckListItemTableViewHeaderDelegate: AnyObject {
	func toggleAllSelected(at section: Int?)
	func toggleAllUnSelected(at section: Int?)
}

final class AddCheckListItemTableViewSectionHeader: UITableViewHeaderFooterView {
	enum AddCheckListItemTableViewSection {
		case selected
		case unselected
	}
	
	// MARK: - UI Component
	private let sectionLabel: UILabel = .init()
	private let sectionButton: UIButton = .init()
	private var section: Int?
	weak var delegate: AddCheckListItemTableViewHeaderDelegate?
	
	convenience init(
		reuseIdentifier: String?,
		section: Int
	) {
		self.init(reuseIdentifier: reuseIdentifier)
		configure(section: section)
	}
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setViewAttributes()
		setViewHeirachies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Helper
extension AddCheckListItemTableViewSectionHeader {
	func configure(section: Int) {
		if section == 0 {
			sectionLabel.text = "선택 항목"
			sectionButton.configureAsUnderlineTextButton(title: "모두 선택해제", color: .primary1)
			sectionButton.addTarget(self, action: #selector(toggleSelectedÅll), for: .touchUpInside)
			self.section = section
		}
		
		if section == 2 {
			sectionLabel.text = "추천 목록"
			sectionButton.configureAsUnderlineTextButton(title: "모두 선택", color: .primary1)
			sectionButton.addTarget(self, action: #selector(toggleUnSelectedÅll), for: .touchUpInside)
			self.section = section
		}
	}
}

// MARK: - Button Method
private extension AddCheckListItemTableViewSectionHeader {
	@objc func toggleSelectedÅll() {
		delegate?.toggleAllSelected(at: section)
	}
	
	@objc func toggleUnSelectedÅll() {
		delegate?.toggleAllUnSelected(at: section)
	}
}

// MARK: - UI Configure
private extension AddCheckListItemTableViewSectionHeader {
	enum LayoutConstant {
		static let horizontalPadding: CGFloat = 20
		static let componentHeight: CGFloat = 18
	}
	
	func setViewAttributes() {
		backgroundColor = .background
		contentView.backgroundColor = .background
		
		sectionLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		sectionLabel.textColor = .gray2
		sectionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		sectionButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHeirachies() {
		contentView.addSubview(sectionLabel)
		contentView.addSubview(sectionButton)
	}
	
	func setViewConstraints() {
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
