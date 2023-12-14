//
//  CRDTMessage.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public protocol CRDTMessage {
	func concat(with message: CRDTMessage) throws -> CRDTMessage
	func execute<T>(on crdt: CRDT<T>) throws
	func clone() throws -> CRDTMessage
	func size() -> Int
}

struct EmptyCRDTMessage: CRDTMessage {
	func concat(with message: CRDTMessage) -> CRDTMessage {
		return message
	}
	
	func execute<T>(on crdt: CRDT<T>) {}
	
	func clone() -> CRDTMessage {
		return self
	}
	
	func size() -> Int {
		return 1
	}
}
