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
	/// 체크리스트 아이템을 삭제하는 액션
	let remove: PassthroughSubject<CheckListItem, Never>
	let transformWith: PassthroughSubject<Void, Never>
	/// 체크리스트를 삭제하는 액션
	let removeCheckList: PassthroughSubject<Void, Never>
}

enum PrivateDetailCheckListState {
	case error(Error)
	case viewLoad(CheckList)
	case updateItem(CheckListItem)
	case dismiss
}
