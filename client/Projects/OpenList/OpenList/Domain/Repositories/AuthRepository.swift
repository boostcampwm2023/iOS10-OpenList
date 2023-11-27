//
//  AuthRepository.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol AuthRepository {
	func postLoginInfo(loginInfo: LoginInfo) async -> LoginResponseDTO?
}
