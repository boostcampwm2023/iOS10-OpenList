//
//  PersistenceUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol PersistenceUseCase {
	func saveCheckList(title: String, items: [CheckListItem]) async -> Bool
	func fetchAllCheckList() async -> [CheckListTableItem]
	func removeCheckList(checklistId: UUID) -> Bool
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
	
	func removeCheckList(checklistId: UUID) -> Bool {
		return checkListRepository.removeCheckList(checklistId)
	}
}
