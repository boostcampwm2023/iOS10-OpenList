//
//  CRDTResponseDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import CRDT
import Foundation

struct CRDTResponseDTO: Decodable {
	let event: String
	let id: UUID
	let data: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case event, id, message
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(String.self, forKey: .event)
		self.id = try container.decode(UUID.self, forKey: .id)
		if let message = try? container.decode(OperationBasedOneMessage.self, forKey: .message) {
			self.data = message
		} else if let messages = try? container.decode(OperationBasedMessagesBag.self, forKey: .message) {
			self.data = messages
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
