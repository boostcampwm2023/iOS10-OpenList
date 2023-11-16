//
//  DefaultPersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class DefaultCheckListRepository {
	private let checkListStorage: CheckListStorage
	
	init(checkListStorage: CheckListStorage) {
		self.checkListStorage = checkListStorage
	}
}

extension DefaultCheckListRepository: CheckListRepository {
	func saveCheckList(id: UUID, title: String) async -> Bool {
		do {
			try await checkListStorage.saveCheckList(id: UUID(), title: title)
			return true
		} catch {
			return false
		}
	}
	
	func fetchAllCheckList() async throws -> [CheckListTableItem] {
		let result = try await checkListStorage.fetchAllCheckList()
		return result.map {
			CheckListTableItem(
				id: $0.id,
				title: $0.title,
				achievementRate: 0.0
			)
		}
	}
}
