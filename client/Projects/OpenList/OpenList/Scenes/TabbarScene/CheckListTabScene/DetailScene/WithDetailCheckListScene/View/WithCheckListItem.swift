//
//  WithCheckListItem.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import UIKit

protocol WithCheckListItemDelegate: AnyObject {
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: WithCheckListItem,
		indexPath: IndexPath
	)
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		indexPath: IndexPath,
		cellId: UUID
	) -> Bool
	func textViewDidChange(_ textView: OpenListTextView)
}

final class WithCheckListItem: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
		static let cellSpacing: CGFloat = 24
		static let imageSize: CGFloat = 30
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textView: OpenListTextView = .init()
	private let userImageView: UserImageView = .init()
	private var indexPath: IndexPath?
	private(set) var cellId: UUID?
	weak var delegate: WithCheckListItemDelegate?
	
	var content: String {
		textView.text ?? ""
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

extension WithCheckListItem {
	func configure(with checkListItem: CheckListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		self.cellId = checkListItem.id
		textView.text = checkListItem.title
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
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.delegate = self

		userImageView.translatesAutoresizingMaskIntoConstraints = false
		userImageView.layer.cornerRadius = LayoutConstant.imageSize / 2
		userImageView.layer.borderColor = UIColor.primary1.cgColor
		userImageView.layer.borderWidth = 1.0
		userImageView.configure(name: "김")
		userImageView.isHidden = true
	}
	
	func setViewHierarchies() {
		contentView.addSubview(checkButton)
		contentView.addSubview(textView)
		contentView.addSubview(userImageView)
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
			checkButton.trailingAnchor.constraint(equalTo: textView.leadingAnchor, constant: -LayoutConstant.spacing),
			checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			userImageView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			userImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
			userImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
		])
	}
	
	@objc func checkButtonDidTap() {
		checkButton.toggleCheckState()
	}
}

extension WithCheckListItem: UITextViewDelegate {
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
		guard
			let delegate,
			let indexPath,
			let cellId
		else { return true }
		return delegate.textView(
			self.textView,
			shouldChangeCharactersIn: range,
			replacementString: text,
			indexPath: indexPath,
			cellId: cellId
		)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		delegate?.textViewDidChange(self.textView)
	}
}
