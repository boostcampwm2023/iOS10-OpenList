//
//  LoginInfo.swift
//  OpenList
//
//  Created by Hoon on 11/27/23.
//

import Foundation

struct LoginInfo: Encodable {
	let identityToken: String
	let authorizationCode: String
	let fullName: String
}
