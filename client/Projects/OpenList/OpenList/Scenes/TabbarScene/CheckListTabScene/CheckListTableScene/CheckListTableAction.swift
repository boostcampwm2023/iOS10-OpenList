//
//  CheckListTableAction.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine
import Foundation

struct CheckListTableInput {
	let viewAppear: PassthroughSubject<Void, Never>
	let removeCheckList: PassthroughSubject<DeleteCheckListItem, Never>
}

enum CheckListTableState {
	case error(_ error: Error)
	case reload(_ items: [CheckListTableItem])
	case delete(_ item: DeleteCheckListItem)
}
