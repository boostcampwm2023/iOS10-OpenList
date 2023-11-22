//
//  OperationBasedMessage.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

protocol OperationBasedMessage: CRDTMessage {
	func execute(on crdt: CRDT<String>) throws
}
