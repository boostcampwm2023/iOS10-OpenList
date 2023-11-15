//
//  AddTabAction.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine

struct AddTabInput {
	let textFieldDidChange: AnyPublisher<String, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
}

enum AddTabState {
	case error(_ error: Error)
	case valid(_ state: Bool)
	case dismiss
}
