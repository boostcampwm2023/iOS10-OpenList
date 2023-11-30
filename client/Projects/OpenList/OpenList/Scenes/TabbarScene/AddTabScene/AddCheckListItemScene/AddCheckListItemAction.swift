//
//  AddCheckListItemAction.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine

struct AddCheckListItemInput {
	let viewDidLoad: PassthroughSubject<Void, Never>
	let nextButtonDidTap: PassthroughSubject<[CheckListItem], Never>
}

enum AddCheckListItemState {
	case viewDidLoad(
		_ recommendChecklistItem: [RecommendChecklistItem],
		_ categoryInfo: CategoryInfo
	)
	case error(_ error: Error?)
	case dismiss
}
