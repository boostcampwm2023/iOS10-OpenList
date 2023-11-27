//
//  LoginUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol LoginUseCase {
	func postLoginInfo(loginInfo: LoginInfo) async -> Bool
}

final class DefaultLoginUseCase {
	private let defaultAuthRepository: AuthRepository
	
	init(defaultAuthRepository: AuthRepository) {
		self.defaultAuthRepository = defaultAuthRepository
	}
}

extension DefaultLoginUseCase: LoginUseCase {
	func postLoginInfo(loginInfo: LoginInfo) async -> Bool {
		guard let result = await defaultAuthRepository.postLoginInfo(loginInfo: loginInfo) else {
			return false
		}
		KeyChain.shared.create(key: "accessToken", token: result.accessToken)
		KeyChain.shared.create(key: "refreshToken", token: result.refreshToken)
		
		return true
	}
}
