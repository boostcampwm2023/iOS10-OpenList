//
//  RGASInsertion.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

struct RGASInsertion<T: Codable>: RGASOperation {
	let type: OpType
	let content: [T]
	let s3vpos: RGASS3Vector?
	let s3vtms: RGASS3Vector
	let offset1: Int
	
	var replica: Int { return s3vtms.sid }
	
	init(type: OpType, content: [T], s3vpos: RGASS3Vector?, s3vtms: RGASS3Vector, off1: Int) {
		self.type = type
		self.content = content
		self.s3vpos = s3vpos
		self.s3vtms = s3vtms
		self.offset1 = off1
	}
	
	init(content: [T], s3vpos: RGASS3Vector?, s3vtms: RGASS3Vector, off1: Int) {
		self.init(type: .insert, content: content, s3vpos: s3vpos, s3vtms: s3vtms, off1: off1)
	}
	
	func clone() -> RGASInsertion {
		return RGASInsertion(
			type: type,
			content: content,
			s3vpos: (s3vpos == nil) ? s3vpos : s3vtms.clone(),
			s3vtms: s3vtms.clone(),
			off1: offset1
		)
	}
}

extension RGASInsertion: CustomDebugStringConvertible {
	var debugDescription: String {
		let s3va = s3vpos?.debugDescription
		let s3vb = s3vtms.debugDescription
		let contentdebugDescription = type == .delete ? "del(" : "ins('\(content)',"
		return "\(contentdebugDescription), sv3pos: \(s3va == nil ? "nil" : s3va!), sv3tms: \(s3vb), off1: \(offset1)"
	}
}
