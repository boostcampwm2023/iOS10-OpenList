//
//  LoginResponseDTO.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

struct LoginResponseDTO: Decodable {
	let accessToken: String
	let refreshToken: String
}
