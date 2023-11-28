//
//  CategoryProgressView.swift
//  OpenList
//
//  Created by Hoon on 11/28/23.
//

import UIKit

enum Progress {
	case major
	case medium
	case sub
}

final class CategoryProgressView: UIView {
	let gradientCircle1 = GradientStageCircle.init()
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		setAttributes()
		setViewHierachies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension CategoryProgressView {
	func setAttributes() {
		gradientCircle1.configure(stage: "1")
	}
	
	func setViewHierachies() {
		[
			gradientCircle1
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			gradientCircle1.centerXAnchor.constraint(equalTo: centerXAnchor),
			gradientCircle1.centerYAnchor.constraint(equalTo: centerYAnchor),
			gradientCircle1.heightAnchor.constraint(equalToConstant: 27),
			gradientCircle1.widthAnchor.constraint(equalToConstant: 27)
		])
	}
}
