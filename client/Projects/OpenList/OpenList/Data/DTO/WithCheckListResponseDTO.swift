//
//  WithCheckListResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Foundation

struct WithCheckListResponseDTO: Decodable {
	let updatedAt: String
	let createdAt: String
	let title: String
	let sharedCheckListId: UUID
	let users: [UserResponseDTO]
	
	enum CodingKeys: String, CodingKey {
		case updatedAt
		case createdAt
		case title
		case sharedCheckListId = "sharedChecklistId"
		case users = "editors"
	}
}
