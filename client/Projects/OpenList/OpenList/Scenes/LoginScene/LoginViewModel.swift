//
//  LoginViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Combine

protocol LoginViewModelable: ViewModelable
where Input == LoginInput,
			State == LoginState,
			Output == AnyPublisher<State, Never> { }

final class LoginViewModel { }

extension LoginViewModel: LoginViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany([
			loginButtonDidTap(input)
		]).eraseToAnyPublisher()
	}
}

private extension LoginViewModel {
	func loginButtonDidTap(_ input: Input) -> Output {
		return input.loginButtonTap
			.withUnretained(self)
			.map { (_, _) in return }
			.eraseToAnyPublisher()
	}
}
