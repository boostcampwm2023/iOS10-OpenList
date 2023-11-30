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
	let messages: [CRDTMessageResponseDTO]
	
	enum CodingKeys: String, CodingKey {
		case updatedAt
		case createdAt
		case itemID = "itemId"
		case messages
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
