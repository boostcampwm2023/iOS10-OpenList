//
//  WithCheckListItemCell.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import UIKit

protocol WithCheckListItemDelegate: AnyObject {
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, cell: WithCheckListItemCell, indexPath: IndexPath)
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		indexPath: IndexPath,
		cellId: UUID
	) -> Bool
	func textFieldDidChange(_ text: String)
	func checklistDidTap(_ indexPath: IndexPath, cellId: UUID, isChecked: Bool)
}

final class WithCheckListItemCell: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
		static let imageSize: CGFloat = 30
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textField: CheckListItemTextField = .init()
	private let userImageView: UserImageView = .init()
	private var indexPath: IndexPath?
	private(set) var cellId: UUID?
	weak var delegate: WithCheckListItemDelegate?
	
	var content: String {
		textField.text ?? ""
	}
	
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

extension WithCheckListItemCell {
	func configure(with checkListItem: any ListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		self.cellId = checkListItem.id
		textField.text = checkListItem.title
		guard let item = checkListItem as? WithCheckListItem else { return }
		if item.isChecked {
			checkButton.setChecked()
		} else {
			checkButton.setUnChecked()
		}
		guard
			let name = item.name,
			let firstChar =	name.first
		else { return }
		userImageView.configure(name: String(firstChar))
	}
	
	func resetUserPosition() {
		userImageView.isHidden = true
	}
}

private extension WithCheckListItemCell {
	func setViewAttributes() {
		backgroundColor = .background
		contentView.isUserInteractionEnabled = true
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
		userImageView.translatesAutoresizingMaskIntoConstraints = false
		userImageView.layer.cornerRadius = LayoutConstant.imageSize / 2
		userImageView.layer.borderColor = UIColor.primary1.cgColor
		userImageView.layer.borderWidth = 1.0
		userImageView.configure(name: "김")
		userImageView.isHidden = true
	}
	
	func setViewHierarchies() {
		contentView.addSubview(checkButton)
		contentView.addSubview(textField)
		contentView.addSubview(userImageView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checkButton.widthAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.width),
			checkButton.heightAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.height),
			checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstant.horizontalPadding),
			checkButton.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -LayoutConstant.spacing),
			checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			userImageView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			userImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
			userImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
			
			textField.topAnchor.constraint(equalTo: checkButton.topAnchor),
			textField.trailingAnchor.constraint(
				equalTo: userImageView.leadingAnchor,
				constant: -LayoutConstant.spacing
			),
			textField.bottomAnchor.constraint(equalTo: checkButton.bottomAnchor)
		])
	}
	
	@objc func checkButtonDidTap() {
		checkButton.toggleCheckState()
		guard let indexPath = indexPath,
					let cellId = cellId
		else { return }
		delegate?.checklistDidTap(indexPath, cellId: cellId, isChecked: checkButton.isChecked)
	}
}

extension WithCheckListItemCell: UITextFieldDelegate {
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
			let indexPath,
			let cellId
		else { return true }
		return delegate.textField(
			self.textField,
			shouldChangeCharactersIn: range,
			replacementString: string,
			indexPath: indexPath,
			cellId: cellId
		)
	}
	
	@objc func textFieldDidChange(_ sender: CheckListItemTextField?) {
		guard let text = sender?.text else { return }
		delegate?.textFieldDidChange(text)
	}
}
