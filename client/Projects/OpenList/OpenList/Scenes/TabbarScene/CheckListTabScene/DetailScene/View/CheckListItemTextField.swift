//
//  CheckListItemTextField.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

final class CheckListItemTextField: UITextField {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension CheckListItemTextField {
	func setViewAttributes() {
		backgroundColor = .background
		textColor = .gray1
		font = UIFont.notoSansCJKkr(type: .medium, size: .small)
		returnKeyType = .done
	}
}
