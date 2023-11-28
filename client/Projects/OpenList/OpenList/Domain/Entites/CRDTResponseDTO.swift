//
//  CRDTResponseDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import CRDT
import Foundation

struct CRDTResponseDTO: Codable {
	let event: String
	let documentNode: LinkedListNode<UUID>
	let data: CRDTMessage
	
	init(event: String, documentNode: LinkedListNode<UUID>, data: CRDTMessage) {
		self.event = event
		self.documentNode = documentNode
		self.data = data
	}
	
	enum CodingKeys: CodingKey {
		case event, documentNode, message
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(String.self, forKey: .event)
		self.documentNode = try container.decode(LinkedListNode<UUID>.self, forKey: .documentNode)
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
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(event, forKey: .event)
		try container.encode(documentNode, forKey: .documentNode)
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
