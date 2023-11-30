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
		case event, data
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(Event.self, forKey: .event)
		
		if let message = try? container.decode(CRDTMessageResponseDTO.self, forKey: .data) {
			self.data = [message]
		} else if let messages = try? container.decode([CRDTMessageResponseDTO].self, forKey: .data) {
			self.data = messages
		} else if let lastDate = try? container.decode(String.self, forKey: .data) {
			self.data = [lastDate]
		} else {
			self.data = []
		}
	}
}

struct CRDTMessageResponseDTO: Decodable {
	let id: UUID
	let message: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case id, message
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		
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
