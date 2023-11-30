//
//  DefaultCRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import CustomNetwork
import CustomSocket

final class DefaultCRDTRepository {
	private let session: CustomSession
	private let crdtStorage: CRDTStorage
	
	init(session: CustomSession = .init(), crdtStorage: CRDTStorage) {
		self.session = session
		self.crdtStorage = crdtStorage
	}
}

extension DefaultCRDTRepository: CRDTRepository {
	func save(message: CRDTMessage) async throws -> CRDTMessage {
		try await crdtStorage.save(message: message)
		return message
	}
	
	func send(id: UUID, message: CRDTMessage) throws {
		let request = CRDTRequestDTO(
			event: .send,
			data: .init(id: id, data: message)
		)
		let data = try JSONEncoder().encode(request)
		dump(data.prettyPrintedJSONString ?? "Couldn't create a .json string.")
		WebSocket.shared.send(data: data)
	}
	
	func fetchCheckListItems(id: UUID) async throws -> [CRDTMessageResponseDTO] {
		var builder = URLRequestBuilder(url: "https://openlist.kro.kr/shared-checklists/\(id.uuidString)")
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		
		builder.setMethod(.get)
		
		let service = NetworkService(
			customSession: session,
			urlRequestBuilder: builder
		)
		
		let responseData = try await service.request()
		dump(responseData.prettyPrintedJSONString)
		let response = try JSONDecoder().decode(WithCheckListItemResponseDTO.self, from: responseData)
		var messages = [CRDTMessageResponseDTO]()
		response.items.forEach { item in
			item.messages.forEach {
				messages.append($0)
			}
		}
		return messages
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
