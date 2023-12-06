//
//  RecommendCheckListUseCase.swift
//  OpenList
//
//  Created by 김영균 on 12/5/23.
//

import Foundation

protocol RecommendCheckListUseCase {
	func fetchRecommendCheckList(by id: Int) async -> Result<[CheckList], Error>
}

final class DefaultRecommendCheckListUseCase {
	private let checklistRepository: CheckListRepository
	
	init(checklistRepository: CheckListRepository) {
		self.checklistRepository = checklistRepository
	}
}

extension DefaultRecommendCheckListUseCase: RecommendCheckListUseCase {
	func fetchRecommendCheckList(by id: Int) async -> Result<[CheckList], Error> {
		do {
			let items = try await checklistRepository.fetchRecommendCheckList(id: id)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
}
