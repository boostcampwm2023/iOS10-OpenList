//
//  RecommendTabAction.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import Combine

struct RecommendTabInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
	let fetchRecommendCheckList: PassthroughSubject<String, Never> // categoryName
}

enum RecommendTabState {
	case reloadRecommendCategory([CategoryItem])
	case reloadRecommendCheckList([FeedCheckList])
	case error(Error?)
}
