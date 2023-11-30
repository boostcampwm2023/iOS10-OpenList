//
//  WithDetailCheckListAction.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine
import Foundation

struct WithDetailCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let socketConnet: PassthroughSubject<Void, Never>
	let insert: PassthroughSubject<EditText, Never>
	let delete: PassthroughSubject<EditText, Never>
	let appendDocument: PassthroughSubject<EditText, Never>
	let removeDocument: PassthroughSubject<EditText, Never>
	let receive: PassthroughSubject<String, Never>
}

enum WithDetailCheckListState {
	case none
	case viewWillAppear(CheckList)
	case updateItem([CheckListItem])
	case appendItem(CheckListItem)
	case removeItem(CheckListItem)
	case socketConnet(Bool)
}
