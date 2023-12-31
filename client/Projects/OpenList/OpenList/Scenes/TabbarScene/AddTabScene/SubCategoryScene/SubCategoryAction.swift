//
//  SubCategoryAction.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine

struct SubCategoryInput {
	let viewLoad: PassthroughSubject<Void, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
	let skipButtonDidTap: AnyPublisher<Void, Never>
	let collectionViewCellDidSelect: PassthroughSubject<String, Never>
}

enum SubCategoryState {
	case error(_ error: Error)
	case load(_ category: [CategoryItem])
	case routeToNext(_ title: String, _ mainCategory: CategoryItem, _ subCategory: CategoryItem)
	case routeToLast(_ categoryInfo: CategoryInfo)
	case none
}
