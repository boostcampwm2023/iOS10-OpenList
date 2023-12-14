//
//  UserResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Foundation

struct UserResponseDTO: Decodable {
	let userId: Int
	let email: String?
	let providerId: String?
	let provider: String?
	let fullName: String?
	let nickname: String?
	let profileImage: String?
	let createdAt: String?
	let updatedAt: String?
}
