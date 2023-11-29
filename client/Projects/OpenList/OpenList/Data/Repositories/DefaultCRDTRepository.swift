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
	
	func send(id: UUID, message: CRDTMessage) throws {
		let request = CRDTRequestDTO(event: Device.id, id: id, data: message)
		let data = try JSONEncoder().encode(request)
		dump(data.prettyPrintedJSONString ?? "Couldn't create a .json string.")
		WebSocket.shared.send(data: data)
	}
	
	func fetchAll() async throws -> [CRDTMessage] {
		let result = try await crdtStorage.fetchAll()
		return result
	}
}

extension Data {
	var prettyPrintedJSONString: NSString? {
		guard
			let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
			let data = try? JSONSerialization.data(
				withJSONObject: jsonObject,
				options: [.prettyPrinted]
			),
			let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		else {
			return nil
		}
		
		return prettyJSON
	}
}
