//
//  DetailCheckListUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/27/23.
//

import CRDT
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
	private let withCheckListRepository: WithCheckListRepository
	private var orderBy: [UUID] = []
	private var checkList: CheckList?
	private let crdtDocumentUseCase: CRDTDocumentUseCase
	
	init(
		checkListRepository: CheckListRepository,
		withCheckListRepository: WithCheckListRepository,
		crdtDocumentUseCase: CRDTDocumentUseCase
	) {
		self.checkListRepository = checkListRepository
		self.withCheckListRepository = withCheckListRepository
		self.crdtDocumentUseCase = crdtDocumentUseCase
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
		guard let checkList else { return false }
		let checkListEditText = checkList.items.map {
			EditText(id: $0.itemId, content: $0.title, range: .init(location: 0, length: $0.title.count))
		}
		
		do {
			// 로컬에서 함께 체크리스트의 데이터로 변환합니다.
			// 함께 체크리스트의 CRDT 메세지로 변환하여 보냅니다.
			let items = try checkListEditText.map { editText in
				let document = crdtDocumentUseCase.createDocument(id: editText.id)
				let operation = crdtDocumentUseCase.createOperation(at: editText, type: .insert, argument: 0)
				let merge = crdtDocumentUseCase.createMerge(id: editText.id, document: document)
				let message = try merge.applyLocal(to: operation)
				return (editTextId: editText.id, message: message)
			}
			
			let isSuccess = await withCheckListRepository.changeToWithCheckList(
				title: checkList.title,
				items: items,
				sharedChecklistId: checkList.id
			)
			guard isSuccess else { return false }
			
			return checkListRepository.removeCheckList(checkList.id)
		} catch {
			return false
		}
	}
}
