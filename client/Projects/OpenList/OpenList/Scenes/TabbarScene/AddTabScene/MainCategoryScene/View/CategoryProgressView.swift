//
//  CategoryProgressView.swift
//  OpenList
//
//  Created by Hoon on 11/28/23.
//

import UIKit

enum Progress {
	case main
	case sub
	case minor
}

final class CategoryProgressView: UIView {
	private let progressStackView: UIStackView = .init()
	private let gradientCircleFirst: GradientStageCircle = .init()
	private let gradientCircleSecond: GradientStageCircle = .init()
	private let gradientCircleThrid: GradientStageCircle = .init()
	private let gradientStickFirst: GradientStageStick = .init()
	private let gradientStickSecond: GradientStageStick = .init()
	
	convenience init(stage: Progress) {
		self.init()
		switch stage {
		case .main:
			gradientCircleFirst.activates()
		case .sub:
			gradientCircleFirst.activates()
			gradientStickFirst.activates()
			gradientCircleSecond.activates()
		case .minor:
			gradientCircleFirst.activates()
			gradientStickFirst.activates()
			gradientCircleSecond.activates()
			gradientStickSecond.activates()
			gradientCircleThrid.activates()
		}
	}
	
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
		setGradientCircle()
		setStackView()
	}
	
	func setGradientCircle() {
		gradientCircleFirst.configure(stage: "1")
		gradientCircleSecond.configure(stage: "2")
		gradientCircleThrid.configure(stage: "3")
	}
	
	func setStackView() {
		progressStackView.axis = .horizontal
		progressStackView.alignment = .center
		progressStackView.distribution = .equalSpacing
		progressStackView.spacing = 10
		progressStackView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierachies() {
		addSubview(progressStackView)
		[
			gradientCircleFirst,
			gradientStickFirst,
			gradientCircleSecond,
			gradientStickSecond,
			gradientCircleThrid
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			progressStackView.addArrangedSubview($0)
		}
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			progressStackView.topAnchor.constraint(equalTo: topAnchor),
			progressStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			progressStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			progressStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
