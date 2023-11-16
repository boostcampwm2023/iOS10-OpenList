//
//  ConfirmButton.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import UIKit

final class ConfirmButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init() {
		super.init(frame: CGRect.zero)
		configure()
	}
	
	convenience init(title: String) {
		self.init()
		configure()
		setTitle(title, for: .normal)
	}
	
	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				backgroundColor = UIColor(red: 72/255, green: 190/255, blue: 91/255, alpha: 1.0)
				setTitleColor(.systemBackground, for: .normal)
			} else {
				layer.borderColor = UIColor(red: 72/255, green: 190/255, blue: 91/255, alpha: 1.0).cgColor
				layer.borderWidth = 1
				backgroundColor = .systemBackground
				setTitleColor(UIColor(red: 72/255, green: 190/255, blue: 91/255, alpha: 1.0), for: .normal)
			}
		}
	}
	
	private func configure() {
		backgroundColor = UIColor(red: 72/255, green: 190/255, blue: 91/255, alpha: 1.0)
		layer.cornerRadius = 10
		titleLabel?.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
	}
}
