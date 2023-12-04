//
//  CRDTResponseDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import CRDT
import Foundation

struct CRDTResponseDTO: Decodable {
	let event: Event
	let data: [Any]
	
	enum CodingKeys: CodingKey {
		case number, event, data
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(Event.self, forKey: .event)
		
		if let message = try? container.decode(CRDTMessageResponseDTO.self, forKey: .data) {
			self.data = [message]
		} else if let messages = try? container.decode([CRDTMessageResponseDTO].self, forKey: .data) {
			self.data = messages
		} else if let deleteDocument = try? container.decode(CRDTDocumentResponseDTO.self, forKey: .data) {
			self.data = [deleteDocument]
		} else if let lastDate = try? container.decode(String.self, forKey: .data) {
			self.data = [lastDate]
		} else {
			self.data = []
		}
	}
}

struct CRDTDocumentResponseDTO: CRDTData, Decodable {
	let id: UUID
	let number: Int
	let event: DocumentEvent
	
	enum CodingKeys: CodingKey {
		case id, number, event
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.number = (try? container.decode(Int.self, forKey: .number)) ?? 0
		self.event = try container.decode(DocumentEvent.self, forKey: .event)
	}
}

struct CRDTMessageResponseDTO: CRDTData, Decodable {
	let id: UUID
	let number: Int
	let message: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case id, number, message
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.number = (try? container.decode(Int.self, forKey: .number)) ?? 0
		
		if let message = try? container.decode(OperationBasedOneMessage.self, forKey: .message) {
			self.message = message
		} else if let messages = try? container.decode(OperationBasedMessagesBag.self, forKey: .message) {
			self.message = messages
		} else {
			throw DecodingError.valueNotFound(
				CRDTMessage.self,
				.init(
					codingPath: [CodingKeys.message],
					debugDescription: "Unknown CRDTMessage type"
				)
			)
		}
	}
}
