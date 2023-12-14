//
//  CheckListItemPlaceholder.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import UIKit

protocol CheckListItemPlaceholderDelegate: AnyObject {
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		indexPath: IndexPath
	)
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool
	func textViewDidChange(_ textView: OpenListTextView)
}

final class CheckListItemPlaceholder: UITableViewCell {
	enum LayoutConstant {
		static let buttonSize = CGSize(width: 24, height: 24)
		static let verticalPadding: CGFloat = 12
		static let horizontalPadding: CGFloat = 20
		static let spacing: CGFloat = 8
		static let cellSpacing: CGFloat = 24
	}
	
	enum Text {
		static let deactivatedPlaceholder = "체크리스트 추가"
	}
	
	// MARK: - Properties
	private let checkButton: CheckListItemButton = .init()
	private let textView: OpenListTextView = .init()
	private var indexPath: IndexPath?
	weak var delegate: CheckListItemPlaceholderDelegate?
	
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

extension CheckListItemPlaceholder {
	func configure(indexPath: IndexPath) {
		self.indexPath = indexPath
	}
}

private extension CheckListItemPlaceholder {
	func setViewAttributes() {
		backgroundColor = .background
		contentView.isUserInteractionEnabled = true
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.isEnabled = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.text = Text.deactivatedPlaceholder
		textView.textColor = .lightGray
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
}

extension CheckListItemPlaceholder: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		// 플레이스 홀더에 작성 중일 때 버튼을 활성화시킵니다.
		if textView.text == Text.deactivatedPlaceholder {
			textView.text = nil
			textView.textColor = .gray1
		}
		checkButton.isEnabled = true
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		guard let indexPath = indexPath else { return }
		// 플레이스 홀더 작성이 완료되었으면 체크 버튼을 비활성화시킵니다.
		checkButton.isEnabled = false
		if let text = textView.text, !text.isEmpty {
			delegate?.textViewDidEndEditing(self.textView, indexPath: indexPath)
		}
		textView.text = Text.deactivatedPlaceholder
		textView.textColor = .lightGray
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
