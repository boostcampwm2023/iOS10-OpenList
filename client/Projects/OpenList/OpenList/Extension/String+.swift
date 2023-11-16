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
