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

struct UpdateItem {
	let indexPath: IndexPath
	let content: String
}

protocol CRDTUseCase {
	func receive(data: Data) async throws -> CheckListItem
	func insert(at editText: EditText) async throws -> CheckListItem
	func delete(at editText: EditText) async throws -> CheckListItem
	func appendDocument(at editText: EditText) async throws -> CheckListItem
	func removeDocument(at editText: EditText) async throws -> CheckListItem
}

final class DefaultCRDTUseCase {
	private let crdtRepository: CRDTRepository
	private var documentDictionary: [UUID: RGASDocument<String>] = [:]
	private var mergeDictionary: [UUID: RGASMerge<String>] = [:]
	private var checkList: [CheckListItem] = []
	private var checkListIndex: [UUID: Int] = [:]
	private var documentsId: LinkedList<UUID> = .init()
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func receive(data: Data) async throws -> CheckListItem {
		guard
			let response = try? JSONDecoder().decode(CRDTResponseDTO.self, from: data),
			response.event != Device.id else {
			throw CRDTUseCaseError.sendMyself
		}
		
		let id = response.documentNode.value
		if documentsId.searchNode(from: id) == nil {
			return try appendCheckListItem(to: id, message: response.data)
		} else {
			return try updateCheckListItem(to: id, message: response.data)
		}
	}
	
	func insert(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		guard let documentNode = documentsId.searchNode(from: id) else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(documentNode: documentNode, message: message)
		return item
	}
	
	func delete(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .delete, argument: 1)
		let id = editText.id
		guard let documentNode = documentsId.searchNode(from: id) else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(documentNode: documentNode, message: message)
		print(message)
		return item
	}
	
	func appendDocument(at editText: EditText) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		documentsId.append(value: id)
		guard let documentNode = documentsId.searchNode(from: id) else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		let (item, message) = try appendCheckListItem(to: id, operation: operation)
		try await updateRepository(documentNode: documentNode, message: message)
		return item
	}
	
	func removeDocument(at editText: EditText) async throws -> CheckListItem {
		fatalError()
	}
}

private extension DefaultCRDTUseCase {
	// MARK: RGASDocument
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
	
	func createDocument(id: UUID) -> RGASDocument<String> {
		let document = RGASDocument<String>()
		documentsId.append(value: id)
		documentDictionary[id] = document
		return document
	}
	
	func createMerge(id: UUID, document: RGASDocument<String>) -> RGASMerge<String> {
		let merge = RGASMerge(doc: document, siteID: 0)
		mergeDictionary[id] = merge
		return merge
	}
	
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
		print(message)
		let title = document.view()
		return (
			item: CheckListItem(itemId: id, title: title, isChecked: false),
			message: message
		)
	}
	
	func updateRepository(documentNode: LinkedListNode<UUID>, message: CRDTMessage) async throws {
		try crdtRepository.send(documentNode: documentNode, message: message)
		try await crdtRepository.save(message: message)
	}
}
