//
//  WithCheckListAction.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine
import Foundation

struct WithCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let removeCheckList: PassthroughSubject<DeleteCheckListItem, Never>
}

enum WithCheckListState {
	case reload(_ items: [WithCheckList])
	case deleteItem(_ item: DeleteCheckListItem)
	case error(_ error: Error)
}
