//
//  OpenListTextView.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import UIKit

final class OpenListTextView: UITextView {
	// MARK: - Initializers
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		setViewAttributes()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension OpenListTextView {
	func setViewAttributes() {
		textContainer.lineFragmentPadding = 0
		textContainerInset = .zero
		isScrollEnabled = false
		backgroundColor = .background
		textColor = .label
		font = UIFont.notoSansCJKkr(type: .medium, size: .small)
		returnKeyType = .done
	}
}
