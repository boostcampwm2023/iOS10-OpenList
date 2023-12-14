//
//  GaugeVIew.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import UIKit

final class GaugeView: UIView {
	private var viewSize: CGSize = .init()
	
	func configure(with rating: Double) {
		let layers = createGaugeLayers(rating)
		self.layer.sublayers = layers
	}
	
	override public var intrinsicContentSize: CGSize {
		return viewSize
	}
}

extension GaugeView {
	func createGaugeLayers(_ rating: Double) -> [CALayer] {
		let gaugeLayer = createGaugeLayer()
		let maskGaugeLayer = createMaskGaugeLayer(rating)
		
		return [gaugeLayer, maskGaugeLayer]
	}
	
	func createGaugeLayer() -> CAGradientLayer {
		let colors: [CGColor] = [
			UIColor(red: 92/255, green: 177/255, blue: 88/255, alpha: 1.0).cgColor,
			UIColor(red: 62/255, green: 240/255, blue: 162/255, alpha: 1.0).cgColor,
			UIColor(red: 56/255, green: 249/255, blue: 215/255, alpha: 1.0).cgColor
		]
		let gaugeLayer = CAGradientLayer()
		gaugeLayer.frame = CGRect(origin: .init(x: 0, y: 0), size: .init(width: 44, height: 4))
		gaugeLayer.colors = colors
		gaugeLayer.startPoint = .init(x: 0.0, y: 0.5)
		gaugeLayer.endPoint = .init(x: 1.0, y: 0.5)
		gaugeLayer.locations = [0.66]
		gaugeLayer.cornerRadius = gaugeLayer.frame.height / 2
		return gaugeLayer
	}
	
	func createMaskGaugeLayer(_ rating: CGFloat) -> CALayer {
		let maskGaugeLayer = CALayer()
		let width = 42 * (1.0 - rating)
		maskGaugeLayer.frame = CGRect(origin: .init(x: 1 + 42 - width, y: 1), size: .init(width: width, height: 2))
		maskGaugeLayer.cornerRadius = maskGaugeLayer.frame.height / 2
		maskGaugeLayer.backgroundColor = UIColor.background.cgColor
		return maskGaugeLayer
	}
}
