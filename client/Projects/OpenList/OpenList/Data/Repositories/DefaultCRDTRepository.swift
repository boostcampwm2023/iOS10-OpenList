//
//  DefaultCRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

final class DefaultCRDTRepository {
	private let crdtStorage: CRDTStorage
	
	init(crdtStorage: CRDTStorage) {
		self.crdtStorage = crdtStorage
	}
}

extension DefaultCRDTRepository: CRDTRepository {
	func save(message: CRDTMessage) async throws -> CRDTMessage {
		try await crdtStorage.save(message: message)
		return message
	}
	
	func fetchAll() async throws -> [CRDTMessage] {
		let result = try await crdtStorage.fetchAll()
		return result
	}
}
