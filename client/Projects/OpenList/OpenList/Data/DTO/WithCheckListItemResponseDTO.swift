//
//  WithCheckListItemResponseDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/30/23.
//

import CRDT
import Foundation

// MARK: - WithCheckListItemResponseDTO
struct WithCheckListItemResponseDTO: Decodable {
	let withChecklist: WithChecklistDTO
	let items: [WithCheckListItemDTO]
	
	enum CodingKeys: String, CodingKey {
		case withChecklist = "sharedChecklist"
		case items
	}
}

// MARK: - WithCheckListItemDTO
struct WithCheckListItemDTO: Decodable {
	let updatedAt: String
	let createdAt: String
	let itemID: Int
	let messages: [CRDTData]
	
	enum CodingKeys: String, CodingKey {
		case updatedAt
		case createdAt
		case itemID = "itemId"
		case messages
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
		self.createdAt = try container.decode(String.self, forKey: .createdAt)
		self.itemID = try container.decode(Int.self, forKey: .itemID)
		
		if let messages = try? container.decode([DecodeMessage].self, forKey: .messages) {
			self.messages = messages.compactMap { datum in
				let id = datum.id
				let number = datum.number
				if let name = datum.name, let state = datum.state {
					return CRDTCheckListToggleResponseDTO(
						id: id,
						number: number,
						name: name,
						state: state
					)
				} else if let name = datum.name, let message = datum.message {
					return CRDTMessageResponseDTO(
						id: id,
						number: number,
						name: name,
						message: message
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
			self.messages = []
		}
	}
}

// MARK: - WithChecklistDTO
struct WithChecklistDTO: Decodable {
	let updatedAt: String
	let createdAt: String
	let title: String
	let sharedChecklistID: String
	
	enum CodingKeys: String, CodingKey {
		case updatedAt
		case createdAt
		case title
		case sharedChecklistID = "sharedChecklistId"
	}
}

struct DecodeMessage: CRDTData, Decodable {
	let id: UUID
	let number: Int
	let event: DocumentEvent?
	let name: String?
	let state: Bool?
	let message: CRDTMessage?
	
	enum CodingKeys: CodingKey {
		case id, number, event, name, state, message
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.number = (try? container.decode(Int.self, forKey: .number)) ?? 0
		self.event = try? container.decode(DocumentEvent.self, forKey: .event)
		self.name = try? container.decode(String.self, forKey: .name)
		self.state = try? container.decode(Bool.self, forKey: .state)
		
		if let message = try? container.decode(OperationBasedOneMessage.self, forKey: .message) {
			self.message = message
		} else if let messages = try? container.decode(OperationBasedMessagesBag.self, forKey: .message) {
			self.message = messages
		} else {
			self.message = nil
		}
	}
}
