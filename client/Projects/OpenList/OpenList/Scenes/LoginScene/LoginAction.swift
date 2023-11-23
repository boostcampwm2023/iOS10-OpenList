//
//  LoginAction.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Combine

import Combine

struct LoginInput {
	let loginButtonTap: AnyPublisher<Void, Never>
}

enum LoginState {
	case error(_ error: Error)
	case success
}
