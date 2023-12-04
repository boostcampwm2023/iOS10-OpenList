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
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UserImageView {
	func configure(name: String) {
		nameLabel.text = name
	}
}

private extension UserImageView {
	func setViewAttributes() {
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
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
