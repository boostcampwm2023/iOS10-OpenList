//
//  AddCheckListItemAction.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine

struct AddCheckListItemInput {
	let configureHeaderView: PassthroughSubject<Void, Never>
	let viewDidLoad: PassthroughSubject<Void, Never>
	let nextButtonDidTap: PassthroughSubject<[CheckListItem], Never>
}

enum AddCheckListItemState {
	case configureHeader(_ categoryInfo: CategoryInfo)
	case viewDidLoad(_ recommendChecklistItem: [RecommendChecklistItem])
	case error(_ error: Error?)
	case dismiss
}
