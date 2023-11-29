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
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 92, height: 2)
	}
}

extension GradientStageStick {
	func activates() {
		setGradientLayer()
		backgroundColor = .clear
	}
}

private extension GradientStageStick {
	func setAttributes() {
		layer.cornerRadius = 1
		backgroundColor = .gray3
	}
	
	func setGradientLayer() {
		let endColor = UIColor.primary1.cgColor.copy(alpha: 0.3)!
		progressGradientLayer.colors = [UIColor.primary1.cgColor, endColor]
		progressGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		progressGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		layer.addSublayer(progressGradientLayer)
	}
}
