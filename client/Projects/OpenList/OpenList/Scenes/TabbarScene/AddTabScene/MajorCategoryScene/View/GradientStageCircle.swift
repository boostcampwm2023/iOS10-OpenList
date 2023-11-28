//
//  GradientStageCircle.swift
//  OpenList
//
//  Created by Hoon on 11/28/23.
//

import UIKit

final class GradientStageCircle: UIView {
	private var progressGradientLayer: CAGradientLayer = .init()
	private let progressPath: UIBezierPath = .init()
	private let progressLayer: CAShapeLayer = .init()
	private let progressLabel: UILabel = .init()
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		drawSetting()
		setAttributes()
		setViewHierachies()
		setConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setProgressPath()
		progressGradientLayer.frame = bounds
	}
}

extension GradientStageCircle {
	func configure(stage: String) {
		progressLabel.text = stage
	}
	
	func activates() {
		setGradientLayer()
		progressLabel.textColor = .primary1
//		progressGradientLayer.mask = progressLayer
	}
}

private extension GradientStageCircle {
	func drawSetting() {
		setProgressPath()
		setProgressLayer()
	}
	
	func setAttributes() {
		setProgressLabel()
	}
	
	func setProgressPath() {
		progressPath.removeAllPoints()
		progressPath.addArc(
			withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
			radius: 12,
			startAngle: 0,
			endAngle: .pi * 2,
			clockwise: true
		)
		progressLayer.path = progressPath.cgPath
	}
	
	func setProgressLayer() {
		progressLayer.lineCap = .round
		progressLayer.strokeColor = UIColor.gray3.cgColor
		progressLayer.lineWidth = 2
		progressLayer.fillColor = UIColor.clear.cgColor
	}
	
	func setProgressLabel() {
		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .small)
		progressLabel.textColor = .gray3
	}
	
	func setGradientLayer() {
		progressGradientLayer.colors = [UIColor.primary1.cgColor, UIColor.systemBackground.cgColor]
		progressGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		progressGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		progressGradientLayer.position = progressLayer.position
		progressGradientLayer.mask = progressLayer
		layer.addSublayer(progressGradientLayer)
	}
	
	func setViewHierachies() {
		layer.addSublayer(progressLayer)
		addSubview(progressLabel)
	}
	
	func setConstraints() {
		NSLayoutConstraint.activate([
			progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
}
