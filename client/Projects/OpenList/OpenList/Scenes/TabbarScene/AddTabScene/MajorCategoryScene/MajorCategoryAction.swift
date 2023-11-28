//
//  MajorCategoryAction.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine

struct MajorCategoryInput {
	let viewLoad: PassthroughSubject<Void, Never>
	let viewWillAppear: PassthroughSubject<Void, Never>
	let nextButtonDidTap: AnyPublisher<Void, Never>
	let collectionViewCellDidSelect: PassthroughSubject<String, Never>
}

enum MajorCategoryState {
	case error(_ error: Error)
	case viewWillAppear(_ title: String)
	case load(_ category: [String])
	case routeToNext(_ category: String)
}
