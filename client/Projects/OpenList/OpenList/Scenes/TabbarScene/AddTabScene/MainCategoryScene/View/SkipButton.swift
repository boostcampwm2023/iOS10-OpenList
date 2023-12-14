//
//  SkipButton.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import UIKit

extension UIButton {
	func configureAsUnderlineTextButton(title: String, color: UIColor) {
		let text = title
		let attributeString = NSMutableAttributedString(string: text)
		let underline = NSUnderlineStyle.thick.rawValue
		let textColor = color
		
		attributeString.addAttribute(
			NSAttributedString.Key.foregroundColor,
			value: textColor,
			range: NSRange(
				location: 0,
				length: text.count
			)
		)
		
		attributeString.addAttribute(
			NSMutableAttributedString.Key.underlineStyle,
			value: underline,
			range: NSRange(
				location: 0,
				length: text.count
			)
		)
		
		titleLabel?.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		setAttributedTitle(attributeString, for: .normal)
		backgroundColor = .clear
		layer.borderWidth = 0
		translatesAutoresizingMaskIntoConstraints = false
	}
}
