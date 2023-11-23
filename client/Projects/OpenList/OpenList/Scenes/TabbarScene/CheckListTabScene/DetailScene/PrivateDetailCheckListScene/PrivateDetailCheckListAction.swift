//
//  DetailCheckListAction.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

struct PrivateDetailCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
}

enum PrivateDetailCheckListState {
	case title(String?)
}
