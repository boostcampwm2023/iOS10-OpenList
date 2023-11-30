//
//  SelectCheckListItem.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import UIKit

protocol SelectCheckListCellDelegate: AnyObject {
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, cell: SelectCheckListCell, indexPath: IndexPath)
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		cellId: UUID
	) -> Bool
	func checkButtonDidToggled(
		_ textField: CheckListItemTextField,
		cell: SelectCheckListCell,
		cellId: UUID
	)
}

final class SelectCheckListCell: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
	}
	
	// MARK: - Properties
	private let checkButton: AddCheckListItemButton = .init()
	private let textField: CheckListItemTextField = .init()
	private var indexPath: IndexPath?
	private var cellId: UUID?
	weak var delegate: SelectCheckListCellDelegate?
	
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

extension SelectCheckListCell {
	func configure(with checkListItem: CheckListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		self.cellId = checkListItem.id
		textField.text = checkListItem.title
		checkButton.setUnChecked()
	}
}

private extension SelectCheckListCell {
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
		guard
			let _ = self.indexPath,
			let cellId = self.cellId
		else { return }
		delegate?.checkButtonDidToggled(textField, cell: self, cellId: cellId)
	}
}

extension SelectCheckListCell: UITextFieldDelegate {
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
