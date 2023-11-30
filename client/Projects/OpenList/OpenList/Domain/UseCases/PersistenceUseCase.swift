//
//  PersistenceUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol PersistenceUseCase {
	func saveCheckList(title: String) async -> Bool
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
	func saveCheckList(title: String) async -> Bool {
		let id = UUID()
		return await checkListRepository.saveCheckList(id: id, title: title)
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
