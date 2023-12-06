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
	func receive(_ jsonString: String) async throws -> [any ListItem]
	func itemChecked(at id: UUID) async throws -> any ListItem
	func begingEdit(at id: UUID) async throws -> any ListItem
	func update(textChange: TextChange, currentText: String) async throws -> any ListItem
	func appendDocument(at editText: EditText) async throws -> any ListItem
	func removeDocument(at editText: EditText) async throws -> any ListItem
	func createDocument(id: UUID) -> RGASDocument<String>
	func updateCheckListState(to id: UUID, isChecked: Bool) async throws
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
	private var historyData: [any ListItem] = []
	private var id: UUID?
	private var crdtMessageDictionay: [UUID: CRDTMessage] = [:]
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func fetchCheckList(id: UUID) async throws -> CheckList {
		self.id = id
		let response = try await crdtRepository.fetchCheckListItems(id: id)
		response.compactMap { item in
			if let item = item as? CRDTDocumentResponseDTO {
				return removeCheckList(to: item.id)
			} else if let item = item as? CRDTMessageResponseDTO {
				if documentsId.searchNode(from: item.id) == nil {
					return try? appendCheckListItem(to: item.id, message: item.message, name: item.name)
				} else {
					// 차후 isChecked 변수값 조정
					return try? updateCheckListItem(to: item.id, message: item.message, name: item.name, isChecked: false)
				}
			} else {
				return nil
			}
		}
		
		// 기록 하나로 합치기.
		let documentIds = documentsId.values()
		let items = documentIds.map { uuid in
			let currentDocument = documentDictionary[uuid]
			let view = currentDocument!.view()
			let items = WithCheckListItem(itemId: uuid, title: view, isChecked: false, name: nil)
			return items
		}
		
		documentDictionary.forEach {
			print($0)
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
	
	func receive(_ jsonString: String) async throws -> [any ListItem] {
		guard let response = CRDTResponseDTO.map(jsonString: jsonString) else {
			throw CRDTUseCaseError.decodeFailed
		}
		switch response.event {
		case .listen:
			if let data = response.data.first as? CRDTCheckListToggleResponseDTO {
				dump("Message Number: \(data.number)")
				if documentsId.searchNode(from: data.id) != nil {
					return [try updateCheckListItem(to: data.id, name: data.name, isChecked: data.state)]
				} else {
					return []
				}
			} else if let data = response.data.first as? CRDTMessageResponseDTO {
				dump("Message Name: \(data.name)")
				dump("Message Number: \(data.number)")
				if documentsId.searchNode(from: data.id) == nil {
					return [try appendCheckListItem(to: data.id, message: data.message, name: data.name)]
				} else {
					return [try updateCheckListItem(to: data.id, message: data.message, name: data.name, isChecked: false)]
				}
			} else if let data = response.data.first as? CRDTDocumentResponseDTO {
				dump("Message Number: \(data.number)")
				switch data.event {
				case .delete:
					return [removeCheckList(to: data.id)]
				case .append:
					return []
				}
			} else {
				throw CRDTUseCaseError.decodeFailed
			}
			
		case .history:
			guard let data = response.data as? [CRDTMessageResponseDTO] else {
				throw CRDTUseCaseError.decodeFailed
			}
			historyData = try data.map {
				if documentsId.searchNode(from: $0.id) == nil {
					try appendCheckListItem(to: $0.id, message: $0.message, name: $0.name)
				} else {
					// 차후에 isChecked field값 조정
					try updateCheckListItem(to: $0.id, message: $0.message, name: $0.name, isChecked: false)
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
	
	func updateCheckListState(to id: UUID, isChecked: Bool) async throws {
		guard let message = crdtMessageDictionay[id] else { return }
		try crdtRepository.checkListStateUpdate(id: id, message: message, isChecked: isChecked)
	}
	
	func itemChecked(at id: UUID) async throws -> any ListItem {
		fatalError()
	}
	
	func begingEdit(at id: UUID) async throws -> any ListItem {
		fatalError()
	}
	
	func update(textChange: TextChange, currentText: String) async throws -> any ListItem {
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
	
	func appendDocument(at editText: EditText) async throws -> any ListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		let (item, message) = try appendCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
	}
	
	func removeDocument(at editText: EditText) async throws -> any ListItem {
		let id = editText.id
		try await removeRepository(id: id)
		let item = removeCheckList(to: id)
		return item
	}
}

private extension DefaultCRDTUseCase {
	// MARK: LengthChange
	func lengthChangeLess(textChange: TextChange, currentText: String) async throws -> any ListItem {
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
	
	func lengthChangeEqual(textChange: TextChange, currentText: String) async throws -> any ListItem {
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
	
	func lengthChangeMore(textChange: TextChange, currentText: String) async throws -> any ListItem {
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
	func insert(at editText: EditText) async throws -> any ListItem {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
	}
	
	func delete(at editText: EditText) async throws -> any ListItem {
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
	
	func replace(at editText: EditText, argument: Int = 1) async throws -> any ListItem {
		let operation = createOperation(at: editText, type: .replace, argument: argument)
		let id = editText.id
		let (item, message) = try updateCheckListItem(to: id, operation: operation)
		try await updateRepository(id: id, message: message)
		return item
	}
	
	// MARK: CheckListItem
	func appendCheckListItem(to id: UUID, message: CRDTMessage, name: String) throws -> any ListItem {
		let document = createDocument(id: id)
		let merge = createMerge(id: id, document: document)
		try message.execute(on: merge)
		let title = document.view()
		crdtMessageDictionay[id] = message
		
		return WithCheckListItem(itemId: id, title: title, isChecked: false, name: name)
	}
	
	func appendCheckListItem(
		to id: UUID,
		operation: SequenceOperation<String>
	) throws -> (item: any ListItem, message: CRDTMessage) {
		let document = createDocument(id: id)
		let merge = createMerge(id: id, document: document)
		let message = try merge.applyLocal(to: operation)
		let title = document.view()
		crdtMessageDictionay[id] = message
		
		return (
			item: WithCheckListItem(itemId: id, title: title, isChecked: false, name: nil),
			message: message
		)
	}
	
	func updateCheckListItem(to id: UUID, message: CRDTMessage, name: String, isChecked: Bool) throws -> any ListItem {
		guard
			let document = documentDictionary[id],
			let merge = mergeDictionary[id]
		else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		try message.execute(on: merge)
		let title = document.view()
		crdtMessageDictionay[id] = message
		
		return WithCheckListItem(itemId: id, title: title, isChecked: isChecked, name: name)
	}
	
	func updateCheckListItem(to id: UUID, name: String, isChecked: Bool) throws -> any ListItem {
		return WithCheckListItem(itemId: id, title: " ", isChecked: isChecked, name: name, isValueChanged: true)
	}
	
	func updateCheckListItem(
		to id: UUID,
		operation: SequenceOperation<String>
	) throws -> (item: any ListItem, message: CRDTMessage) {
		guard
			let document = documentDictionary[id],
			let merge = mergeDictionary[id]
		else {
			throw CRDTUseCaseError.docmuentNotFound
		}
		let message = try merge.applyLocal(to: operation)
		let title = document.view()
		crdtMessageDictionay[id] = message
		
		return (
			item: WithCheckListItem(itemId: id, title: title, isChecked: false, name: nil),
			message: message
		)
	}
	
	func removeCheckList(to id: UUID) -> any ListItem {
		documentsId.remove(value: id)
		documentDictionary.removeValue(forKey: id)
		mergeDictionary.removeValue(forKey: id)
		crdtMessageDictionay[id] = nil
		
		return WithCheckListItem(itemId: id, title: "", isChecked: false, name: nil)
	}
	
	func removeRepository(id: UUID) async throws {
		try crdtRepository.documentDelete(id: id)
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
