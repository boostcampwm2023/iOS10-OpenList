//
//  CRDTUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

enum CRDTUseCaseError: Error {
	case docmuentNotFound
	case decodeFailed
	case typeIsNil
}

protocol CRDTUseCase {
	func fetchCheckList(id: UUID) async throws -> CheckList
	func receive(_ jsonString: String) async throws -> [CheckListItem]
	func itemChecked(at id: UUID) async throws -> CheckListItem
	func begingEdit(at id: UUID) async throws -> CheckListItem
	func update(textChange: TextChange, currentText: String) async throws -> CheckListItem
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
	private var historyData: [CheckListItem] = []
	private var id: UUID?
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func fetchCheckList(id: UUID) async throws -> CheckList {
		self.id = id
		let response = try await crdtRepository.fetchCheckListItems(id: id)
		let items = response.compactMap {
			if documentsId.searchNode(from: $0.id) == nil {
				try? appendCheckListItem(to: $0.id, message: $0.message)
			} else {
				try? updateCheckListItem(to: $0.id, message: $0.message)
			}
		}
		return .init(
			id: id,
			title: "Test",
			createdAt: .now,
			updatedAt: .now,
			progress: 0,
			orderBy: [],
			items: items
		)
	}
	
	func receive(_ jsonString: String) async throws -> [CheckListItem] {
		guard let response = CRDTResponseDTO.map(jsonString: jsonString) else {
			throw CRDTUseCaseError.decodeFailed
		}
		switch response.event {
		case .listen:
			guard let data = response.data.first as? CRDTMessageResponseDTO else {
				throw CRDTUseCaseError.decodeFailed
			}
			dump("Message Number: \(data.number)")
			if documentsId.searchNode(from: data.id) == nil {
				return [try appendCheckListItem(to: data.id, message: data.message)]
			} else {
				return [try updateCheckListItem(to: data.id, message: data.message)]
			}
			
		case .history:
			guard let data = response.data as? [CRDTMessageResponseDTO] else {
				throw CRDTUseCaseError.decodeFailed
			}
			historyData = try data.map {
				if documentsId.searchNode(from: $0.id) == nil {
					try appendCheckListItem(to: $0.id, message: $0.message)
				} else {
					try updateCheckListItem(to: $0.id, message: $0.message)
				}
			}
			return historyData
			
		case .lastDate:
			throw CRDTUseCaseError.decodeFailed
			
		default:
			dump(response)
			throw CRDTUseCaseError.docmuentNotFound
		}
	}
	
	func itemChecked(at id: UUID) async throws -> CheckListItem {
		fatalError()
	}
	
	func begingEdit(at id: UUID) async throws -> CheckListItem {
		fatalError()
	}
	
	func update(textChange: TextChange, currentText: String) async throws -> CheckListItem {
		#if DEBUG
		defer {
			printDocument(text: currentText, id: textChange.id)
		}
		#endif
		
		let oldString = textChange.oldString
		let lengthChange = Comparison(currentText.count, oldString.count)
		
		switch lengthChange {
		case .less:
			return try await lengthChangeLess(textChange: textChange, currentText: currentText)
		case .equal:
			return try await lengthChangeEqual(textChange: textChange, currentText: currentText)
		case .more:
			return try await lengthChangeMore(textChange: textChange, currentText: currentText)
		}
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
	// MARK: LengthChange
	func lengthChangeLess(textChange: TextChange, currentText: String) async throws -> CheckListItem {
		let range = textChange.range
		let oldString = textChange.oldString
		let id = textChange.id
		let replacementString = textChange.replacementString
		
		if range.location == 0 {
			return try await delete(at: .init(id: id, content: replacementString, range: range))
		} else {
			let location = range.location - 1
			let currentString = currentText.subString(offsetBy: location)
			let prevString = oldString.subString(offsetBy: location)
			
			if currentString == prevString {
				return try await delete(at: .init(id: id, content: replacementString, range: range))
			} else {
				return try await replace(
					at: .init(
						id: id,
						content: currentString,
						range: .init(location: location, length: range.length)
					),
					argument: 2
				)
			}
		}
	}
	
	func lengthChangeEqual(textChange: TextChange, currentText: String) async throws -> CheckListItem {
		let range = textChange.range
		let id = textChange.id
		let location: Int = (range.length == 0) ? range.location - 1 : range.location
		let string = currentText.subString(offsetBy: location)
		return try await replace(
			at: .init(
				id: id,
				content: string,
				range: .init(location: location, length: range.length)
			)
		)
	}
	
	func lengthChangeMore(textChange: TextChange, currentText: String) async throws -> CheckListItem {
		let range = textChange.range
		let id = textChange.id
		
		var string = currentText.subString(offsetBy: range.location)
		guard let value2 = UnicodeScalar(String(string))?.value else {
			throw CRDTUseCaseError.typeIsNil
		}
		if value2 < 0xac00 {
			return try await insert(at: .init(id: id, content: string, range: range))
		} else {
			let location = range.location - 1
			let prevString = currentText.subString(offsetBy: location)
			string = prevString + string
			return try await replace(
				at: .init(
					id: id,
					content: string,
					range: .init(location: location, length: range.length + 1)
				)
			)
		}
	}
	
	// MARK: Operation
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
	
	func replace(at editText: EditText, argument: Int = 1) async throws -> CheckListItem {
		let operation = createOperation(at: editText, type: .replace, argument: argument)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
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

#if DEBUG
extension DefaultCRDTUseCase {
	func printDocument(text: String, id: UUID) {
		guard let document = documentDictionary[id] else {
			return
		}
		if text != document.view() {
			dump("ListedChain with sep: \(document.viewWithSeparator())")
			dump("Size of doc: \(document.viewLength())")
			dump("ListedChain view: \(document.view())")
			print(document.treeViewWithSeparator(tree: document.root, depth: 0))
		} else {
			dump("Text and document are the same")
		}
	}
}
#endif
