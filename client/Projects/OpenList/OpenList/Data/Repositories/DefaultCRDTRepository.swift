//
//  DefaultCRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import CustomSocket

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
	
	func send(documentNode: LinkedListNode<UUID>, message: CRDTMessage) throws {
		let request = CRDTRequestDTO(event: Device.id, documentNode: documentNode, data: message)
		let data = try JSONEncoder().encode(request)
		WebSocket.shared.send(data: data)
	}
	
	func fetchAll() async throws -> [CRDTMessage] {
		let result = try await crdtStorage.fetchAll()
		return result
	}
}
