//
//  WithCheckListUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/30/23.
//

import Foundation

enum WithCheckListUseCaseError: Error {
	case failedDelete
}

protocol WithCheckListUseCase {
	func fetchAllCheckList() async -> [WithCheckList]
	func removeCheckList(to item: DeleteCheckListItem) async throws -> DeleteCheckListItem
}

final class DefaultWithCheckListUseCase {
	private let withCheckListRepository: WithCheckListRepository
	
	init(withCheckListRepository: WithCheckListRepository) {
		self.withCheckListRepository = withCheckListRepository
	}
}

extension DefaultWithCheckListUseCase: WithCheckListUseCase {
	func fetchAllCheckList() async -> [WithCheckList] {
		return await withCheckListRepository.fetchAllSharedCheckList()
	}
	
	func removeCheckList(to item: DeleteCheckListItem) async throws -> DeleteCheckListItem {
		let result = try await withCheckListRepository.removeCheckList(item.id)
		guard result else { throw WithCheckListUseCaseError.failedDelete }
		return item
	}
}
