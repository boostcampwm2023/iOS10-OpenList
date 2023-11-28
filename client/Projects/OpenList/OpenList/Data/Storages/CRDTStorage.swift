//
//  CRDTStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

protocol CRDTStorage {
	func save(message: CRDTMessage) async throws
	func fetchAll() async throws -> [CRDTMessage]
}
