//
//  CheckListTableAction.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine

struct CheckListTableInput {
	let viewLoad: PassthroughSubject<Void, Never>
}

enum CheckListTableState {
	case error(_ error: Error)
	case reload(_ items: [CheckListTableItem])
}
