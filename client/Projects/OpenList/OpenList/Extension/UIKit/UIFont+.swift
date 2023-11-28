//
//  UIFont+.swift
//  OpenList
//
//  Created by wi_seong on 11/15/23.
//

import UIKit

extension UIFont {
	enum Constant {
		static let notoSansCJKkr = "NotoSansCJKkr"
		static let medinumType = "-Medium"
		static let regularType = "-Regular"
	}
	
	static func notoSansCJKkr(type: NotoSansCJKkrType, size: FontSize) -> UIFont? {
		let name = Constant.notoSansCJKkr
		guard let font = UIFont(name: name + type.name, size: size.rawValue) else {
			print("Do not Font")
			return nil
		}
		return font
	}
	
	enum FontSize: CGFloat {
		case extra = 24.0
		case large = 20.0
		case medium = 16.0
		case small = 14.0
	}
	
	enum NotoSansCJKkrType {
		case medium
		case regular
		
		var name: String {
			switch self {
			case .medium:
				return Constant.medinumType
			case .regular:
				return Constant.regularType
			}
		}
	}
}
