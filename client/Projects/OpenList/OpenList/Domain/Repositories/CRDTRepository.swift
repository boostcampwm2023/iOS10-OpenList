//
//  CRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import Foundation

protocol CRDTRepository {
	func save(message: CRDTMessage) async throws -> CRDTMessage
	func fetchAll() async throws -> [CRDTMessage]
}
