//
//  LocalCheckListItem.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

protocol LocalCheckListItemDelegate: AnyObject {
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: LocalCheckListItem,
		indexPath: IndexPath
	)
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool
	func didChangedCheckButton(
		_ textView: OpenListTextView,
		cell: LocalCheckListItem,
		indexPath: IndexPath,
		isChecked: Bool
	)
	func textViewDidChange(_ textView: OpenListTextView)
}

final class LocalCheckListItem: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
		static let cellSpacing: CGFloat = 24
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textView: OpenListTextView = .init()
	private var indexPath: IndexPath?
	private(set) var id: UUID = UUID()
	private(set) var isChecked: Bool = false
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
		id = checkListItem.id
		isChecked = checkListItem.isChecked
		textView.text = checkListItem.title
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
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.delegate = self
	}
	
	func setViewHierarchies() {
		contentView.addSubview(checkButton)
		contentView.addSubview(textView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checkButton.widthAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.width),
			checkButton.heightAnchor.constraint(equalToConstant: LayoutConstant.buttonSize.height),
			checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstant.horizontalPadding),
			checkButton.trailingAnchor.constraint(equalTo: textView.leadingAnchor, constant: -LayoutConstant.spacing),
			checkButton.topAnchor.constraint(equalTo: textView.topAnchor),
			
			textView.topAnchor.constraint(equalTo: contentView.topAnchor),
			textView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			textView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -LayoutConstant.cellSpacing
			)
		])
	}
	
	@objc func checkButtonDidTap() {
		checkButton.toggleCheckState()
		isChecked = checkButton.isChecked
		guard
			let delegate,
			let indexPath
		else { return }
		delegate.didChangedCheckButton(
			textView,
			cell: self,
			indexPath: indexPath,
			isChecked: isChecked
		)
	}
}

extension LocalCheckListItem: UITextViewDelegate {
	func textViewDidEndEditing(_ textView: UITextView) {
		guard let indexPath = indexPath else { return }
		delegate?.textViewDidEndEditing(self.textView, cell: self, indexPath: indexPath)
	}
	
	func textView(
		_ textView: UITextView,
		shouldChangeTextIn range: NSRange,
		replacementText text: String
	) -> Bool {
		guard text != "\n" else {
			textView.resignFirstResponder()
			return false
		}
		guard let delegate else { return true }
		return delegate.textView(
			self.textView,
			shouldChangeCharactersIn: range,
			replacementString: text
		)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		delegate?.textViewDidChange(self.textView)
	}
}
