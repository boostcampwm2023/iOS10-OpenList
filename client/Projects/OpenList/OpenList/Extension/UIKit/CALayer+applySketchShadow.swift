//
//  CALayer+applySketchShadow.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

// swiftlint:disable identifier_name
extension CALayer {
	func applySketchShadow(
		color: CGColor,
		blur: CGFloat,
		alpha: Float = 1,
		x: CGFloat = 0,
		y: CGFloat = 0,
		spread: CGFloat = 0
	) {
		shadowColor = color
		shadowOpacity = alpha
		shadowOffset = CGSize(width: x, height: y)
		shadowRadius = blur / 2
		if spread == 0 {
			shadowPath = nil
		} else {
			let dx = -spread
			let rect = bounds.insetBy(dx: dx, dy: dx)
			shadowPath = UIBezierPath(rect: rect).cgPath
		}
		masksToBounds = false
	}
}
// swiftlint:enable identifier_name
