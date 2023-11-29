//
//  LoginAction.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Combine

struct LoginInput {
	let loginButtonTap: PassthroughSubject<LoginInfo, Never>
}

enum LoginState {
	case error
	case success
}
