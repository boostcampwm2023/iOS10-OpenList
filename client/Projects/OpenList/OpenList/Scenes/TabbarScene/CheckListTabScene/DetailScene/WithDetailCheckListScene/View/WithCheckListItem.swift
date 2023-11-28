//
//  WithCheckListItem.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import UIKit

protocol WithCheckListItemDelegate: AnyObject {
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, cell: WithCheckListItem, indexPath: IndexPath)
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		cellId: UUID
	) -> Bool
}

final class WithCheckListItem: UITableViewCell {
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
	private var cellId: UUID?
	weak var delegate: WithCheckListItemDelegate?
	
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

extension WithCheckListItem {
	func configure(with checkListItem: CheckListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		self.cellId = checkListItem.id
		textField.text = checkListItem.title
		if checkListItem.isChecked {
			checkButton.setChecked()
		} else {
			checkButton.setUnChecked()
		}
	}
}

private extension WithCheckListItem {
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

extension WithCheckListItem: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let indexPath = indexPath else { return }
		delegate?.textFieldDidEndEditing(self.textField, cell: self, indexPath: indexPath)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		guard
			let delegate,
			let cellId
		else { return true }
		return delegate.textField(
			self.textField,
			shouldChangeCharactersIn: range,
			replacementString: string,
			cellId: cellId
		)
	}
}
