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
	func updateItem(_ item: CheckListItem) async -> CheckListItem?
	func removeItem(_ item: CheckListItem) async -> CheckListItem?
}

final class DefaultDetailCheckListUseCase {
	private let checkListRepository: CheckListRepository
	private var checkListId: UUID?
	private var orderBy: [UUID] = []
	
	init(checkListRepository: CheckListRepository) {
		self.checkListRepository = checkListRepository
	}
}

extension DefaultDetailCheckListUseCase: DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList? {
		do {
			var response = try await checkListRepository.fetchCheckList(id: id)
			checkListId = id
			orderBy = response.orderBy
			let itemDictionary = Dictionary(uniqueKeysWithValues: response.items.map { ($0.id, $0) })
			let newItems: [CheckListItem] = response.orderBy.compactMap {
				return itemDictionary[$0]
			}
			response.items = newItems
			return response
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
	
	func updateItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard let checkListId else { return nil }
			try await checkListRepository.updateCheckList(id: checkListId, item: item)
			return item
		} catch {
			return nil
		}
	}
	
	func removeItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard
				let checkListId,
				let deleteIndex = orderBy.firstIndex(where: { $0 == item.id })
			else { return nil }
			orderBy.remove(at: deleteIndex)
			try await checkListRepository.removeCheckList(id: checkListId, item: item, orderBy: orderBy)
			return item
		} catch {
			return nil
		}
	}
}
