//
//  AddCheckListTitleAction.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine

struct AddCheckListTitleInput {
	let textFieldDidChange: AnyPublisher<String, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
}

enum AddCheckListTitleState {
	case error(_ error: Error)
	case valid(_ state: Bool)
	case dismiss
}
