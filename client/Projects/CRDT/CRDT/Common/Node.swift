//
//  Node.swift
//  crdt
//
//  Created by wi_seong on 11/21/23.
//

import Foundation

public struct Node: Codable {
	public let event: String
	public let data: CRDTMessage
	
	public init(event: String, data: CRDTMessage) {
		self.event = event
		self.data = data
	}
	
	enum CodingKeys: CodingKey {
		case id, message
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(String.self, forKey: .id)
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
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(event, forKey: .id)
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
