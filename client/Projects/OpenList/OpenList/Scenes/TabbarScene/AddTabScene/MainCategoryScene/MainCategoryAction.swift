//
//  MainCategoryAction.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine

struct MainCategoryInput {
	let viewLoad: PassthroughSubject<Void, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
	let collectionViewCellDidSelect: PassthroughSubject<String, Never>
}

enum MainCategoryState {
	case error(_ error: Error)
	case load(_ category: [CategoryItem])
	case routeToNext(_ category: CategoryItem)
	case none
}
