//
//  DetailCheckListAction.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

struct DetailCheckListInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
}

enum DetailCheckListState {
	case title(String?)
}
