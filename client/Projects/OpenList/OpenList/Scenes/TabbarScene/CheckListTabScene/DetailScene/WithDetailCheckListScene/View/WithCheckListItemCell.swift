//
//  WithCheckListItemCell.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import UIKit

protocol WithCheckListItemCellDelegate: AnyObject {
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: WithCheckListItemCell,
		indexPath: IndexPath
	)
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		indexPath: IndexPath,
		cellId: UUID
	) -> Bool
	func withCheckListTextViewDidChange(_ textView: OpenListTextView)
	func checklistDidTap(_ indexPath: IndexPath, cellId: UUID, isChecked: Bool)
}

final class WithCheckListItemCell: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
		static let imageSize: CGFloat = 30
		static let cellSpacing: CGFloat = 24
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textView: OpenListTextView = .init()
	private let userImageView: UserImageView = .init()
	private var indexPath: IndexPath?
	private(set) var cellId: UUID?
	weak var delegate: WithCheckListItemCellDelegate?
	
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

extension WithCheckListItemCell {
	func configure(with checkListItem: any ListItem, indexPath: IndexPath) {
		self.indexPath = indexPath
		self.cellId = checkListItem.id
		textView.text = checkListItem.title
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
			
			userImageView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			userImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
			userImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.imageSize),
			
			textView.topAnchor.constraint(equalTo: contentView.topAnchor),
			textView.trailingAnchor.constraint(
				equalTo: userImageView.leadingAnchor,
				constant: -LayoutConstant.spacing
			),
			textView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -LayoutConstant.cellSpacing
			)
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


extension WithCheckListItemCell: UITextViewDelegate {
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
		delegate?.withCheckListTextViewDidChange(self.textView)
	}
}
