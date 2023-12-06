//
//  WithCheckListItemResponseDTO.swift
//  OpenList
//
//  Created by wi_seong on 11/30/23.
//

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
		if let messages = try? container.decode([CRDTMessageResponseDTO].self, forKey: .messages) {
			self.messages = messages
		} else if let messages = try? container.decode([CRDTCheckListToggleResponseDTO].self, forKey: .messages) {
			self.messages = messages
		} else if let messages = try? container.decode([CRDTDocumentResponseDTO].self, forKey: .messages) {
			self.messages = messages
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
