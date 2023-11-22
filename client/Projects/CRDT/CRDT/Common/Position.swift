//
//  Position.swift
//  crdt
//
//  Created by wi_seong on 11/20/23.
//

import Foundation

struct Position<T: Codable & Equatable> {
	var node: RGASNode<T>?
	var offset: Int
	
	init(node: RGASNode<T>? = nil, offset: Int) {
		self.node = node
		self.offset = offset
	}
}

extension Position: CustomDebugStringConvertible {
	var debugDescription: String {
		return "[\(node), \(offset)]"
	}
}
