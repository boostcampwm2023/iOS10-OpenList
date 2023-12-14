//
//  SettingAction.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Combine

struct SettingInput {
	let viewDidLoad: PassthroughSubject<Void, Never>
	let logOut: PassthroughSubject<Void, Never>
	let deleteAccount: PassthroughSubject<Void, Never>
}

enum SettingState {
	case reload(_ items: [SettingItem])
	case showLogin
}
