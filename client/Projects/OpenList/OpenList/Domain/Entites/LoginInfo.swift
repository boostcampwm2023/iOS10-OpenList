//
//  LoginInfo.swift
//  OpenList
//
//  Created by Hoon on 11/27/23.
//

import Foundation

struct LoginInfo: Codable {
	let identityToken: String
	let authorizationCode: String
	let fullName: String
}
