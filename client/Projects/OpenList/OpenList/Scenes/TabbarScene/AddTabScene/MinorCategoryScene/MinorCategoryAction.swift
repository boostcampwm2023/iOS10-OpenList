//
//  MinorCategoryAction.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine

struct MinorCategoryInput {
	let viewLoad: PassthroughSubject<Void, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
	let skipButtonDidTap: AnyPublisher<Void, Never>
	let collectionViewCellDidSelect: PassthroughSubject<String, Never>
}

enum MinorCategoryState {
	case error(_ error: Error)
	case load(_ category: [CategoryItem])
	case routeToNext(_ category: CategoryInfo)
	case none
}
