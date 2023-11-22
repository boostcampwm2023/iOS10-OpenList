//
//  Node.swift
//  crdt
//
//  Created by wi_seong on 11/21/23.
//

import Foundation

public struct Node: Codable {
	public let id: String
	public let message: CRDTMessage
	
	public init(id: String, message: CRDTMessage) {
		self.id = id
		self.message = message
	}
	
	enum CodingKeys: CodingKey {
		case id, message
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
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
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		if let myMessage = message as? OperationBasedOneMessage {
			try container.encode(myMessage, forKey: .message)
		} else if let myMessages = message as? OperationBasedMessagesBag {
			try! container.encode(myMessages, forKey: .message)
		} else {
			throw EncodingError.invalidValue(
				message,
				EncodingError.Context(
					codingPath: [CodingKeys.message],
					debugDescription: "Unknown CRDTMessage type")
			)
		}
	}
}
