//
//  ProfileAction.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Combine

struct ProfileInput {
	let viewDidLoad: PassthroughSubject<Void, Never>
}

enum ProfileState {
	case viewDidLoad(_ user: User)
}
