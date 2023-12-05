//
//  RecommendTabAction.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import Combine

struct RecommendTabInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let fetchRecommendCheckList: PassthroughSubject<Int, Never> // categoryId
}

enum RecommendTabState {
	case reloadRecommendCategory([CategoryItem])
	case reloadRecommendCheckList([CheckList])
	case error(Error?)
}
