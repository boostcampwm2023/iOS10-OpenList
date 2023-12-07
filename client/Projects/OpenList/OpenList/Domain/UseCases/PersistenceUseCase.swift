//
//  PersistenceUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

enum PersistenceUseCaseError: Error {
	case failedDelete
}

protocol PersistenceUseCase {
	func saveCheckList(title: String, items: [CheckListItem]) async -> Bool
	func fetchAllCheckList() async -> [CheckListTableItem]
	func removeCheckList(to item: DeleteCheckListItem) async throws -> DeleteCheckListItem
	func removeCheckList(checklistId: UUID) async -> Bool
}

final class DefaultPersistenceUseCase {
	private let checkListRepository: CheckListRepository
	
	init(checkListRepository: CheckListRepository) {
		self.checkListRepository = checkListRepository
	}
}

extension DefaultPersistenceUseCase: PersistenceUseCase {
	func saveCheckList(title: String, items: [CheckListItem]) async -> Bool {
		let id = UUID()
		var unCheckedItems: [CheckListItem] = []
		for item in items {
			unCheckedItems.append(.init(itemId: item.id, title: item.title, isChecked: false))
		}
		return await checkListRepository.saveCheckList(id: id, title: title, items: unCheckedItems)
	}
	
	func fetchAllCheckList() async -> [CheckListTableItem] {
		do {
			let items = try await checkListRepository.fetchAllCheckList()
			return items
		} catch {
			return []
		}
	}
	
	func removeCheckList(to item: DeleteCheckListItem) async throws -> DeleteCheckListItem {
		let result = await checkListRepository.removeCheckList(item.id)
		guard result else { throw PersistenceUseCaseError.failedDelete }
		return item
	}
	
	func removeCheckList(checklistId: UUID) async -> Bool {
		return await checkListRepository.removeCheckList(checklistId)
	}
}
