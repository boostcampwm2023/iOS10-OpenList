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
	let data: [CRDTData]
	
	enum CodingKeys: CodingKey {
		case number, event, data
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.event = try container.decode(Event.self, forKey: .event)
		
		if let message = try? container.decode(CRDTMessageResponseDTO.self, forKey: .data) {
			self.data = [message]
		} else if let checkToggleMessage = try? container.decode(CRDTCheckListToggleResponseDTO.self, forKey: .data) {
			self.data = [checkToggleMessage]
		} else if let messages = try? container.decode([CRDTMessageResponseDTO].self, forKey: .data) {
			self.data = messages
		} else if let deleteDocument = try? container.decode(CRDTDocumentResponseDTO.self, forKey: .data) {
			self.data = [deleteDocument]
		} else if let messages = try? container.decode([DecodeMessage].self, forKey: .data) {
			self.data = messages.compactMap { datum in
				let id = datum.id
				let number = datum.number
				if let name = datum.name, let message = datum.message, let state = datum.state {
					return CRDTMessageResponseDTO(
						id: id,
						number: number,
						name: name,
						state: state,
						message: message
					)
				} else if let name = datum.name, let state = datum.state {
					return CRDTCheckListToggleResponseDTO(
						id: id,
						number: number,
						name: name,
						state: state
					)
				} else if let event = datum.event {
					return CRDTDocumentResponseDTO(
						id: id,
						number: number,
						event: event
					)
				} else {
					return nil
				}
			}
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
	
	init(id: UUID, number: Int, event: DocumentEvent) {
		self.id = id
		self.number = number
		self.event = event
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
	let name: String
	let state: Bool
	let message: CRDTMessage
	
	enum CodingKeys: CodingKey {
		case id, number, name, state, message
	}
	
	init(id: UUID, number: Int, name: String, state: Bool, message: CRDTMessage) {
		self.id = id
		self.number = number
		self.name = name
		self.state = state
		self.message = message
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.number = try container.decode(Int.self, forKey: .number)
		self.name = try container.decode(String.self, forKey: .name)
		self.state = try container.decode(Bool.self, forKey: .state)
		
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

struct CRDTCheckListToggleResponseDTO: CRDTData, Decodable {
	let id: UUID
	let number: Int
	let name: String
	let state: Bool
	
	enum CodingKeys: CodingKey {
		case id, number, name, state
	}
	
	init(id: UUID, number: Int, name: String, state: Bool) {
		self.id = id
		self.number = number
		self.name = name
		self.state = state
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.number = (try? container.decode(Int.self, forKey: .number)) ?? 0
		self.name = try container.decode(String.self, forKey: .name)
		self.state = try container.decode(Bool.self, forKey: .state)
	}
}
