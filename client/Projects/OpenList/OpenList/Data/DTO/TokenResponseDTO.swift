//
//  LoginResponseDTO.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

struct TokenResponseDTO: Decodable {
	let accessToken: String
	let refreshToken: String
}
