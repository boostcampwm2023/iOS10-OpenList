//
//  WithCheckListUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/30/23.
//

import Foundation

protocol WithCheckListUseCase {
	func fetchAllCheckList() async -> [CheckListTableItem]
}

final class DefaultWithCheckListUseCase {
	private let withCheckListRepository: WithCheckListRepository
	
	init(withCheckListRepository: WithCheckListRepository) {
		self.withCheckListRepository = withCheckListRepository
	}
}

extension DefaultWithCheckListUseCase: WithCheckListUseCase {
	func fetchAllCheckList() async -> [CheckListTableItem] {
		do {
			return try await withCheckListRepository.fetchAllCheckList()
		} catch {
			dump(error)
			return []
		}
	}
}
