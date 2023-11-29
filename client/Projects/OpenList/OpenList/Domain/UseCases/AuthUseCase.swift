//
//  AuthUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

enum AuthKey {
	static let accessToken = "accessToken"
	static let refreshToken = "refreshToken"
}

protocol AuthUseCase {
	func postLoginInfo(loginInfo: LoginInfo) async -> Bool
}

final class DefaultAuthUseCase {
	private let defaultAuthRepository: AuthRepository
	
	init(defaultAuthRepository: AuthRepository) {
		self.defaultAuthRepository = defaultAuthRepository
	}
}

extension DefaultAuthUseCase: AuthUseCase {
	func postLoginInfo(loginInfo: LoginInfo) async -> Bool {
		guard let result = await defaultAuthRepository.postLoginInfo(loginInfo: loginInfo) else {
			return false
		}
		KeyChain.shared.create(key: AuthKey.accessToken, token: result.accessToken)
		KeyChain.shared.create(key: AuthKey.refreshToken, token: result.refreshToken)
		
		return true
	}
}
