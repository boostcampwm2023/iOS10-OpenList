//
//  RecommendCheckListUseCase.swift
//  OpenList
//
//  Created by 김영균 on 12/5/23.
//

import Foundation

protocol RecommendCheckListUseCase {
	func fetchFeedCheckList(by mainCategory: String) async -> Result<[FeedCheckList], Error>
}

final class DefaultRecommendCheckListUseCase {
	private let checklistRepository: CheckListRepository
	
	init(checklistRepository: CheckListRepository) {
		self.checklistRepository = checklistRepository
	}
}

extension DefaultRecommendCheckListUseCase: RecommendCheckListUseCase {
	func fetchFeedCheckList(by mainCategory: String) async -> Result<[FeedCheckList], Error> {
		do {
			let items = try await checklistRepository.fetchFeedCheckList(by: mainCategory)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
}
