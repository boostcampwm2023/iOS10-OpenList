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
		let result = await defaultAuthRepository.postLoginInfo(identityToken: identityToken, provider: provider)
		return result
	}
}
