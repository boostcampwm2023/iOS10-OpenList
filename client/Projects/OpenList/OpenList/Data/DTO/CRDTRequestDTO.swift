//
//  CRDTRequestDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/25/23.
//

import CRDT
import Foundation

protocol CRDTData {
	var id: UUID { get }
	var number: Int { get }
}

struct CRDTRequestDTO: Encodable {
	let event: Event
	let data: CRDTData
	
	enum CodingKeys: CodingKey {
		case event, data
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(event, forKey: .event)
		if let data = data as? CRDTDocumentRequestDTO {
			try container.encode(data, forKey: .data)
		} else if let data = data as? CRDTMessageRequestDTO {
			try container.encode(data, forKey: .data)
		} else {
			throw EncodingError.invalidValue(
				data,
				.init(codingPath: [CodingKeys.data], debugDescription: "Data failed Encode")
			)
		}
	}
}

enum Event: String, Codable {
	case send
	case listen
	case history
	case lastDate
}

struct CRDTDocumentRequestDTO: CRDTData, Encodable {
	let id: UUID
	let number: Int
	let event: DocumentEvent
	
	enum CodingKeys: CodingKey {
		case id, number, event
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(number, forKey: .number)
		try container.encode(event, forKey: .event)
	}
}

enum DocumentEvent: String, Codable {
	case delete
	case append
}

struct CRDTMessageRequestDTO: CRDTData, Encodable {
	let id: UUID
	let number: Int
	let name: String
	let data: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case id, number, name, message
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(number, forKey: .number)
		try container.encode(name, forKey: .name)
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
