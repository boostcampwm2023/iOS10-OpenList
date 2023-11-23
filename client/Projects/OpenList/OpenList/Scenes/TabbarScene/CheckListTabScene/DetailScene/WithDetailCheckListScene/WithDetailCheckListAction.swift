//
//  WithDetailCheckListAction.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine

struct WithDetailCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let socketConnet: PassthroughSubject<Void, Never>
	let insert: PassthroughSubject<Range<String.Index>, Never>
	let delete: PassthroughSubject<Range<String.Index>, Never>
}

enum WithDetailCheckListState {
	case title(String?)
	case update(String)
	case socketConnet(Bool)
}
