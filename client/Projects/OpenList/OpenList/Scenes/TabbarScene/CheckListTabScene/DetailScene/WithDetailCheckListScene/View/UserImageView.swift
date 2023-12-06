//
//  UserImageView.swift
//  OpenList
//
//  Created by Hoon on 12/4/23.
//

import UIKit

final class UserImageView: UIImageView {
	private let nameLabel: UILabel = .init()
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHeirachies()
		setViewConstrainst()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UserImageView {
	func configure(name: String) {
		nameLabel.text = name
		isHidden = false
	}
}

private extension UserImageView {
	func setViewAttributes() {
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.font = .notoSansCJKkr(type: .regular, size: .tiny)
		nameLabel.textColor = .primary1
	}
	
	func setViewHeirachies() {
		addSubview(nameLabel)
	}
	
	func setViewConstrainst() {
		NSLayoutConstraint.activate([
			nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
}
