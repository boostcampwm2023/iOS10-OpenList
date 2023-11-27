//
//  LoginDTO.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

struct LoginResponseDTO: Codable {
	let accessToken: String
	let refreshToken: String
}
