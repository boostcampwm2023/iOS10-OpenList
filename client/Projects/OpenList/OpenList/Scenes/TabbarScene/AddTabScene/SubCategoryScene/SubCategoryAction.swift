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
	let collectionViewCellDidSelect: PassthroughSubject<String, Never>
}

enum SubCategoryState {
	case error(_ error: Error)
	case load(_ category: [String])
	case routeToNext(_ category: Category)
	case none
}
