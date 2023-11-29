//
//  CRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import Foundation

protocol CRDTRepository {
	@discardableResult
	func save(message: CRDTMessage) async throws -> CRDTMessage
	func send(id: UUID, message: CRDTMessage) throws
	func fetchAll() async throws -> [CRDTMessage]
}
