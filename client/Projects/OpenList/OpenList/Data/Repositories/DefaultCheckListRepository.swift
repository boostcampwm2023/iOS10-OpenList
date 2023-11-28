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
				id: $0.checklistId,
				title: $0.title,
				achievementRate: Double($0.progress)
			)
		}
	}
	
	func fetchCheckList(id: UUID) async throws -> CheckList {
		let result = try await checkListStorage.fetchCheckList(id: id)
		return .init(
			id: result.checklistId,
			title: result.title,
			createdAt: result.createdAt,
			updatedAt: result.updatedAt,
			progress: result.progress,
			items: result.items.map {
				.init(
					itemId: $0.itemId,
					title: $0.content,
					isChecked: $0.isChecked
				)
			}
		)
	}
}
