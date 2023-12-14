//
//  String+.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

extension String? {
	var orEmpty: String {
		self == nil ? "" : self!
	}
}

extension String {
	func subString(offsetBy: Int) -> String {
		let index = self.index(self.startIndex, offsetBy: offsetBy)
		return String(self[index])
	}
}
