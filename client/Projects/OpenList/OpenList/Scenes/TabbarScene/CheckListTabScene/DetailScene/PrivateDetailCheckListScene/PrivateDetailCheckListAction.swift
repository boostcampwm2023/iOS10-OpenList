//
//  DetailCheckListAction.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

struct PrivateDetailCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let append: PassthroughSubject<CheckListItem, Never>
	let update: PassthroughSubject<CheckListItem, Never>
	let remove: PassthroughSubject<CheckListItem, Never>
	let transformWith: PassthroughSubject<Void, Never>
}

enum PrivateDetailCheckListState {
	case error(Error)
	case viewLoad(CheckList)
	case updateItem(CheckListItem)
	case dismiss
}
