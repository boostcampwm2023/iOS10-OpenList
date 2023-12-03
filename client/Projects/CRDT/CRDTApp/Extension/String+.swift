//
//  String+.swift
//  CRDTApp
//
//  Created by wi_seong on 12/3/23.
//

import Foundation

extension String {
	func subString(offsetBy: Int) -> String {
		let index = self.index(self.startIndex, offsetBy: offsetBy)
		return String(self[index])
	}
}
