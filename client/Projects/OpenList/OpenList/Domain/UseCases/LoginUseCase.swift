//
//  LoginUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol LoginUseCase {
	func postLoginInfo(identityToken: String, provider: String) async -> Bool
}

final class DefaultLoginUseCase {
	private let defaultAuthRepository: AuthRepository
	
	init(defaultAuthRepository: AuthRepository) {
		self.defaultAuthRepository = defaultAuthRepository
	}
}

extension DefaultLoginUseCase: LoginUseCase {
	func postLoginInfo(identityToken: String, provider: String) async -> Bool {
		guard let result = await defaultAuthRepository.postLoginInfo(
			identityToken: identityToken,
			provider: provider
		) else {
			return false
		}
		KeyChain.create(key: "accessToken", token: result.accessToken)
		KeyChain.create(key: "refreshToken", token: result.refreshToken)
		
		return true
	}
}
