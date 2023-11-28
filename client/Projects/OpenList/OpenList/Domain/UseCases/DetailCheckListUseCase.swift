//
//  DetailCheckListUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/27/23.
//

import Foundation

protocol DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList?
	func appendItem(_ item: CheckListItem) async -> CheckListItem?
	func updateItem(_ item: CheckListItem) async -> CheckList?
	func removeItem(_ item: CheckListItem) async -> CheckList?
}

final class DefaultDetailCheckListUseCase {
	private let checkListRepository: CheckListRepository
	private var checkListId: UUID?
	
	init(checkListRepository: CheckListRepository) {
		self.checkListRepository = checkListRepository
	}
}

extension DefaultDetailCheckListUseCase: DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList? {
		do {
			var item = try await checkListRepository.fetchCheckList(id: id)
			checkListId = id
			item.items.sort(by: { $0.index < $1.index })
			return item
		} catch {
			return nil
		}
	}
	
	func appendItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard let checkListId else { return nil }
			try await checkListRepository.appendCheckList(id: checkListId, item: item)
			return item
		} catch {
			return nil
		}
	}
	
	func updateItem(_ item: CheckListItem) async -> CheckList? {
		do {
			guard let checkListId else { return nil }
			let item = try await checkListRepository.updateCheckList(id: checkListId, item: item)
			return item
		} catch {
			return nil
		}
	}
	
	func removeItem(_ item: CheckListItem) async -> CheckList? {
		do {
			guard let checkListId else { return nil }
			let item = try await checkListRepository.removeCheckList(id: checkListId, item: item)
			return item
		} catch {
			return nil
		}
	}
}
