//
//  DefaultPersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class DefaultCheckListRepository {
	private let checkListStorage: PrivateCheckListStorage
	
	init(checkListStorage: PrivateCheckListStorage) {
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
					index: $0.index,
					title: $0.content,
					isChecked: $0.isChecked
				)
			}
		)
	}
	
	func appendCheckList(id: UUID, item: CheckListItem) async throws {
		return try await checkListStorage.appendCheckListItem(id: id, item: item)
	}
	
	func updateCheckList(id: UUID, item: CheckListItem) async throws -> CheckList {
		let result = try await checkListStorage.updateCheckListItem(id: id, item: item)
		return .init(
			id: result.checklistId,
			title: result.title,
			createdAt: result.createdAt,
			updatedAt: result.updatedAt,
			progress: result.progress,
			items: result.items.map {
				.init(
					itemId: $0.itemId,
					index: $0.index,
					title: $0.content,
					isChecked: $0.isChecked
				)
			}
		)
	}
	
	func removeCheckList(id: UUID, item: CheckListItem) async throws -> CheckList {
		let result = try await checkListStorage.removeCheckListItem(id: id, item: item)
		return .init(
			id: result.checklistId,
			title: result.title,
			createdAt: result.createdAt,
			updatedAt: result.updatedAt,
			progress: result.progress,
			items: result.items.map {
				.init(
					itemId: $0.itemId,
					index: $0.index,
					title: $0.content,
					isChecked: $0.isChecked
				)
			}
		)
	}
}
