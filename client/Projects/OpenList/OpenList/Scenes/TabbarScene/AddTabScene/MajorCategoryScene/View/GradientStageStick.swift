//
//  GradientStageStick.swift
//  OpenList
//
//  Created by Hoon on 11/28/23.
//

import UIKit

final class GradientStageStick: UIView {
	private let progressGradientLayer: CAGradientLayer = .init()
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		setAttributes()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		progressGradientLayer.frame = bounds
	}
}

extension GradientStageStick {
	func activates() {
		setGradientLayer()
	}
}

private extension GradientStageStick {
	func setAttributes() {
		translatesAutoresizingMaskIntoConstraints = false
		layer.cornerRadius = 1
		backgroundColor = .gray3
	}
	
	func setGradientLayer() {
		progressGradientLayer.colors = [UIColor.primary1.cgColor, UIColor.systemBackground.cgColor]
		progressGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		progressGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		layer.addSublayer(progressGradientLayer)
	}
}
