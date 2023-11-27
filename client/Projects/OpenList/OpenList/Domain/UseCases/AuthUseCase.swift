//
//  AuthUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

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
		KeyChain.shared.create(key: "accessToken", token: result.accessToken)
		KeyChain.shared.create(key: "refreshToken", token: result.refreshToken)
		
		return true
	}
}
