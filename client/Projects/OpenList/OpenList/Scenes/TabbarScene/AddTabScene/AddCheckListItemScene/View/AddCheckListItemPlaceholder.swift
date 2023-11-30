//
//  AddCheckListItemPlaceholder.swift
//  OpenList
//
//  Created by wi_seong on 11/30/23.
//

import UIKit

protocol AddCheckListItemPlaceholderDelegate: AnyObject {
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, indexPath: IndexPath)
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool
}

final class AddCheckListItemPlaceholder: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
	}
	
	enum Text {
		static let deactivatedPlaceholder = "체크리스트 추가"
	}
	
	// MARK: - Properties
	private let checkButton: AddCheckListItemButton = .init()
	private let textField: CheckListItemTextField = .init()
	private var indexPath: IndexPath?
	weak var delegate: AddCheckListItemPlaceholderDelegate?
	
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

extension AddCheckListItemPlaceholder {
	func configure(indexPath: IndexPath) {
		self.indexPath = indexPath
	}
}

private extension AddCheckListItemPlaceholder {
	func setViewAttributes() {
		backgroundColor = .background
		contentView.isUserInteractionEnabled = true
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.isEnabled = false
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = Text.deactivatedPlaceholder
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
}

extension AddCheckListItemPlaceholder: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// 플레이스 홀더에 작성 중일 때 버튼을 활성화시킵니다.
		checkButton.isEnabled = true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let indexPath = indexPath else { return }
		// 플레이스 홀더에 작성한 텍스트가 있을 경우 뷰컨에 전달하여 체크리스트에 추가합니다.
		if let text = textField.text, !text.isEmpty {
			delegate?.textFieldDidEndEditing(self.textField, indexPath: indexPath)
		}
		// 플레이스 홀더 작성이 완료되었으면 체크 버튼을 비활성화시킵니다.
		checkButton.isEnabled = false
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
		guard let delegate else { return true }
		return delegate.textField(self.textField, shouldChangeCharactersIn: range, replacementString: string)
	}
}
