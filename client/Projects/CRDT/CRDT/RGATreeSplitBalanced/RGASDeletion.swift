//
//  RGASDeletion.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

struct RGASDeletion<T>: RGASOperation {
	let type: OpType
	let s3vpos: RGASS3Vector
	let offset1: Int
	let offset2: Int
	
	var replica: Int { return s3vpos.sid }
	
	init(type: OpType, s3vpos: RGASS3Vector, off1: Int, off2: Int) {
		self.type = type
		self.s3vpos = s3vpos
		self.offset1 = off1
		self.offset2 = off2
	}
	
	init(s3vpos: RGASS3Vector, off1: Int, off2: Int) {
		self.init(type: .delete, s3vpos: s3vpos, off1: off1, off2: off2)
	}
	
	func clone() -> RGASDeletion {
		return RGASDeletion(
			type: type,
			s3vpos: s3vpos.clone(),
			off1: offset1,
			off2: offset2
		)
	}
}

extension RGASDeletion: CustomDebugStringConvertible {
	var debugDescription: String {
		let s3va = s3vpos.debugDescription
		return "del, sv3pos: \(s3va), off1: \(offset1), off2: \(offset2)"
	}
}
