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
	func transformWith() async -> Bool
}

final class DefaultDetailCheckListUseCase {
	private let checkListRepository: CheckListRepository
	private var orderBy: [UUID] = []
	private var checkList: CheckList?
	
	init(checkListRepository: CheckListRepository) {
		self.checkListRepository = checkListRepository
	}
}

extension DefaultDetailCheckListUseCase: DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList? {
		do {
			var response = try await checkListRepository.fetchCheckList(id: id)
			orderBy = response.orderBy
			let itemDictionary = Dictionary(uniqueKeysWithValues: response.items.map { ($0.id, $0) })
			let newItems: [CheckListItem] = response.orderBy.compactMap {
				return itemDictionary[$0]
			}
			response.items = newItems
			self.checkList = response
			return response
		} catch {
			return nil
		}
	}
	
	func appendItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard let checkList else { return nil }
			self.checkList?.items.append(item)
			try await checkListRepository.appendCheckList(id: checkList.id, item: item)
			return item
		} catch {
			return nil
		}
	}
	
	func updateItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard
				let checkList,
				let index = checkList.items.firstIndex(where: { $0.id == item.id })
			else { return nil }
			self.checkList?.items[index] = item
			try await checkListRepository.updateCheckList(id: checkList.id, item: item)
			return item
		} catch {
			return nil
		}
	}
	
	func removeItem(_ item: CheckListItem) async -> CheckListItem? {
		do {
			guard
				let checkList,
				let deleteIndex = orderBy.firstIndex(where: { $0 == item.id })
			else { return nil }
			orderBy.remove(at: deleteIndex)
			self.checkList?.items.remove(at: deleteIndex)
			try await checkListRepository.removeCheckList(id: checkList.id, item: item, orderBy: orderBy)
			return item
		} catch {
			return nil
		}
	}
	
	func transformWith() async -> Bool {
		do {
			guard let checkList else { return false }
			try await checkListRepository.transfromToWith(id: checkList.id)
			return true
		} catch {
			return false
		}
	}
}
