//
//  LocalCheckListItem.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

protocol LocalCheckListItemDelegate: AnyObject {
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, cell: LocalCheckListItem, indexPath: IndexPath)
}

final class LocalCheckListItem: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textField: CheckListItemTextField = .init()
	private var indexPath: IndexPath?
	weak var delegate: LocalCheckListItemDelegate?
	
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
	func configure(with checkListItem: CheckListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		textField.text = checkListItem.title
		if checkListItem.isChecked {
			checkButton.setChecked()
		} else {
			checkButton.setUnChecked()
		}
	}
}

private extension LocalCheckListItem {
	func setViewAttributes() {
		backgroundColor = .background
		contentView.isUserInteractionEnabled = true
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
	}
	
	func setViewHierarchies() {
		contentView.addSubview(checkButton)
		contentView.addSubview(textField)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checkButton.widthAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.width),
			checkButton.heightAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.height),
			checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstant.horizontalPadding),
			checkButton.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -LayoutConstant.spacing),
			checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			textField.topAnchor.constraint(equalTo: checkButton.topAnchor),
			textField.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			textField.bottomAnchor.constraint(equalTo: checkButton.bottomAnchor)
		])
	}
	
	@objc func checkButtonDidTap() {
		checkButton.toggleCheckState()
	}
}

extension LocalCheckListItem: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let indexPath = indexPath else { return }
		delegate?.textFieldDidEndEditing(self.textField, cell: self, indexPath: indexPath)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
