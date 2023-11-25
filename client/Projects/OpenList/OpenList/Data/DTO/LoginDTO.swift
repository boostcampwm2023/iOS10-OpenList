//
//  LoginDTO.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

struct LoginRequestDTO: Codable {
	let identityToken: String
	let provider: String
}

struct LoginResponseDTO: Codable {
	let accessToken: String
	let refreshToken: String
}
