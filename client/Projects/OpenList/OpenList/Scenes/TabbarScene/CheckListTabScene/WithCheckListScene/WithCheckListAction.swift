//
//  WithCheckListAction.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine

struct WithCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
}

enum WithCheckListState {
	case reload(_ items: [WithCheckList])
	case error(_ error: Error)
}
