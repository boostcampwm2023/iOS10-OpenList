//
//  Comparison.swift
//  CRDTApp
//
//  Created by wi_seong on 12/3/23.
//

import Foundation

enum Comparison {
	case less
	case equal
	case more
	
	init(_ lhs: Int, _ rhs: Int) {
		if lhs < rhs {
			self = .less
		} else if lhs == rhs {
			self = .equal
		} else {
			self = .more
		}
	}
}
