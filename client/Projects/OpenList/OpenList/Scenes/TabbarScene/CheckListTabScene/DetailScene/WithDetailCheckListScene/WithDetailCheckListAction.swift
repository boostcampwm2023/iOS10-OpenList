//
//  WithDetailCheckListAction.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine
import Foundation

struct WithDetailCheckListInput {
	let viewLoad: PassthroughSubject<Void, Never>
	let socketConnet: PassthroughSubject<Void, Never>
	let textShouldChange: PassthroughSubject<TextChange, Never>
	let textDidChange: PassthroughSubject<WithCheckListItemChange, Never>
	let appendDocument: PassthroughSubject<EditText, Never>
	let removeDocument: PassthroughSubject<EditText, Never>
	let receive: PassthroughSubject<String, Never>
	let checklistDidTap: PassthroughSubject<CheckToggle, Never>
	let deleteCheckList: PassthroughSubject<Void, Never>
}

enum WithDetailCheckListState {
	case none
	case viewLoad(CheckList)
	case updateItems([any ListItem])
	case appendItem(any ListItem)
	case removeItem(any ListItem)
	case checkToggle
	case socketConnet(Bool)
	case dismiss
}
