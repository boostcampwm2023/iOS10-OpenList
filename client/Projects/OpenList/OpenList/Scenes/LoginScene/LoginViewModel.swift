//
//  LoginViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Combine
import Foundation

protocol LoginViewModelable: ViewModelable
where Input == LoginInput,
	State == LoginState,
	Output == AnyPublisher<State, Never> { }

final class LoginViewModel {
	private let loginUseCase: LoginUseCase
	
	init(loginUseCase: LoginUseCase) {
		self.loginUseCase = loginUseCase
	}
}

extension LoginViewModel: LoginViewModelable {
	func transform(_ input: LoginInput) -> AnyPublisher<LoginState, Never> {
		let loginDidRequest = loginDidRequest(input)
		return Publishers.MergeMany([
			loginDidRequest
		]).eraseToAnyPublisher()
	}
}

extension LoginViewModel {
	func loginDidRequest(_ input: Input) -> Output {
		return input.loginButtonTap
			.withUnretained(self)
			.map { (owner, identityToken) in
				Task {
					let result = await owner.loginUseCase.postLoginInfo(identityToken: identityToken, provider: "APPLE")
					print(result)
				}
				return LoginState.success
			}.eraseToAnyPublisher()
	}
}
