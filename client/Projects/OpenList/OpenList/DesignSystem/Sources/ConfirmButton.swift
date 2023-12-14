//
//  ConfirmButton.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import UIKit

final class ConfirmButton: UIButton {
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIScreen.main.bounds.width - 40, height: 56)
	}
	
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
				backgroundColor = .primary1
				setTitleColor(.white, for: .normal)
			} else {
				layer.borderColor = UIColor.primary1.cgColor
				layer.borderWidth = 1
				backgroundColor = .background
				setTitleColor(.primary1, for: .normal)
			}
		}
	}
	
	private func configure() {
		backgroundColor = .primary1
		layer.cornerRadius = 10
		titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
	}
}
