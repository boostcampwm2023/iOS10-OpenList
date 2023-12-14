//
//  LocalCheckListItem.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

final class LocalCheckListItem: UITableViewCell {
	enum State {
		case deactivated
		case activated
	}
	
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textField: CheckListItemTextField = .init()
	
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

extension LocalCheckListItem {
	func configure(with checkListItem: CheckListItem) {
		if checkListItem.isActivated {
			checkButton.setState(.activated)
			textField.setState(with: checkListItem.title, for: .activated)
		} else {
			checkButton.setState(.deactivated)
			textField.setState(for: .deactivated)
		}
	}
}

private extension LocalCheckListItem {
	func setViewAttributes() {
		contentView.isUserInteractionEnabled = true
		
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.setState(.deactivated)
		checkButton.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.setState(for: .deactivated)
	}
	
	func setViewHierarchies() {
		contentView.addSubview(checkButton)
		contentView.addSubview(textField)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checkButton.widthAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.width),
			checkButton.heightAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.height),
			checkButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstant.horizontalPadding),
			checkButton.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -LayoutConstant.spacing),
			checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			textField.topAnchor.constraint(equalTo: checkButton.topAnchor),
			textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstant.horizontalPadding),
			textField.bottomAnchor.constraint(equalTo: checkButton.bottomAnchor)
		])
	}
	
	@objc func checkButtonDidTap() {
		checkButton.toggleCheckState()
	}
}
