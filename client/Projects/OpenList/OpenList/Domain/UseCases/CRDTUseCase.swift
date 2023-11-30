//
//  CRDTUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

enum CRDTUseCaseError: Error {
	case docmuentNotFound
	case sendMyself
}

protocol CRDTUseCase {
	func fetchCheckList(id: UUID) async throws -> CheckList
	func receive(data: Data) async throws -> CheckListItem
	func itemChecked(at id: UUID) async throws -> CheckListItem
	func begingEdit(at id: UUID) async throws -> CheckListItem
	func insert(at editText: EditText) async throws -> CheckListItem
	func delete(at editText: EditText) async throws -> CheckListItem
	func appendDocument(at editText: EditText) async throws -> CheckListItem
	func removeDocument(at editText: EditText) async throws -> CheckListItem
	func createDocument(id: UUID) -> RGASDocument<String>
}

protocol CRDTDocumentUseCase {
	func createDocument(id: UUID) -> RGASDocument<String>
	func createOperation(at editText: EditText, type: OpType, argument: Int) -> SequenceOperation<String>
	func createMerge(id: UUID, document: RGASDocument<String>) -> RGASMerge<String>
}

final class DefaultCRDTUseCase {
	private let crdtRepository: CRDTRepository
	private var documentDictionary: [UUID: RGASDocument<String>] = [:]
	private var mergeDictionary: [UUID: RGASMerge<String>] = [:]
	private var documentsId: LinkedList<UUID> = .init()
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func fetchCheckList(id: UUID) async throws -> CheckList {
		return .init(
			id: id,
			title: "Test",
			createdAt: .now,
			updatedAt: .now,
			progress: 0,
			orderBy: [],
			items: []
		)
	}
	
	func receive(data: Data) async throws -> CheckListItem {
		guard
			let response = try? JSONDecoder().decode(CRDTResponseDTO.self, from: data),
			response.event != Device.id else {
			throw CRDTUseCaseError.sendMyself
		}
		
		let id = response.id
		if documentsId.searchNode(from: id) == nil {
			return try appendCheckListItem(to: id, message: response.data)
		} else {
			return try updateCheckListItem(to: id, message: response.data)
		}
	}
	
	func itemChecked(at id: UUID) async throws -> CheckListItem {
		fatalError()
	}
	
	func begingEdit(at id: UUID) async throws -> CheckListItem {
		fatalError()
	}
	
	func insert(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
	}
	
	func delete(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .delete, argument: 1)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		if item.title.isEmpty {
			documentsId.remove(value: id)
			documentDictionary.removeValue(forKey: id)
			mergeDictionary.removeValue(forKey: id)
		}
		return item
	}
	
	func appendDocument(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		let (item, message) = try appendCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
	}
	
	func removeDocument(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .delete, argument: editText.range.length)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		documentsId.remove(value: id)
		documentDictionary.removeValue(forKey: id)
		mergeDictionary.removeValue(forKey: id)
		return item
	}
}

private extension DefaultCRDTUseCase {
	// MARK: CheckListItem
	func appendCheckListItem(to id: UUID, message: CRDTMessage) throws -> CheckListItem {
		let document = createDocument(id: id)
		let merge = createMerge(id: id, document: document)
		try message.execute(on: merge)
		let title = document.view()
		
		return CheckListItem(itemId: id, title: title, isChecked: false)
	}
	
	func appendCheckListItem(
		to id: UUID,
		operation: SequenceOperation<String>
	) throws -> (item: CheckListItem, message: CRDTMessage) {
		let document = createDocument(id: id)
		let merge = createMerge(id: id, document: document)
		let message = try merge.applyLocal(to: operation)
		let title = document.view()
		
		return (
			item: CheckListItem(itemId: id, title: title, isChecked: false),
			message: message
		)
	}
	
	func updateCheckListItem(to id: UUID, message: CRDTMessage) throws -> CheckListItem {
		guard
			let document = documentDictionary[id],
			let merge = mergeDictionary[id]
		else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		try message.execute(on: merge)
		let title = document.view()
		return CheckListItem(itemId: id, title: title, isChecked: false)
	}
	
	func updateCheckListItem(
		to id: UUID,
		operation: SequenceOperation<String>
	) throws -> (item: CheckListItem, message: CRDTMessage) {
		guard
			let document = documentDictionary[id],
			let merge = mergeDictionary[id]
		else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		let message = try merge.applyLocal(to: operation)
		dump(message)
		let title = document.view()
		return (
			item: CheckListItem(itemId: id, title: title, isChecked: false),
			message: message
		)
	}
	
	func updateRepository(id: UUID, message: CRDTMessage) async throws {
		try crdtRepository.send(id: id, message: message)
		try await crdtRepository.save(message: message)
	}
}

extension DefaultCRDTUseCase: CRDTDocumentUseCase {
	func createDocument(id: UUID) -> RGASDocument<String> {
		let document = RGASDocument<String>()
		documentsId.append(value: id)
		documentDictionary[id] = document
		return document
	}
	
	func createOperation(
		at editText: EditText,
		type: OpType,
		argument: Int
	) -> SequenceOperation<String> {
		let content = editText.content.map { String($0) }
		let operation = SequenceOperation(
			type: type,
			position: editText.range.location,
			argument: argument,
			content: content
		)
		return operation
	}
	
	func createMerge(id: UUID, document: RGASDocument<String>) -> RGASMerge<String> {
		let merge = RGASMerge(doc: document, siteID: 0)
		mergeDictionary[id] = merge
		return merge
	}
}
