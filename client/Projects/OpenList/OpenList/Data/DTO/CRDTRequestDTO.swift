//
//  CRDTRequestDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import CRDT
import Foundation

struct CRDTRequestDTO: Encodable {
	let event: Event
	let data: CRDTMessageRequestDTO
}

enum Event: String, Codable {
	case send
	case listen
	case history
	case lastDate
}

struct CRDTMessageRequestDTO: Encodable {
	let id: UUID
	let data: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case id, message
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		if let myMessage = data as? OperationBasedOneMessage {
			try container.encode(myMessage, forKey: .message)
		} else if let myMessages = data as? OperationBasedMessagesBag {
			try container.encode(myMessages, forKey: .message)
		} else {
			throw EncodingError.invalidValue(
				data,
				EncodingError.Context(
					codingPath: [CodingKeys.message],
					debugDescription: "Unknown CRDTMessage type")
			)
		}
	}
}
