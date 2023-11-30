//
//  FolderResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import Foundation

struct FolderResponseDTO: Decodable {
	let folderId: Int
	let title: String
	let user: UserResponseDTO
	let createdAt: String
	let updatedAt: String
	
	enum CodingKeys: String, CodingKey {
		case folderId
		case title
		case user = "owner"
		case createdAt
		case updatedAt
	}
}
