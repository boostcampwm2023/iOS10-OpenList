//
//  CRDTUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import CustomSocket

enum CRDTUseCaseError: Error {
	case sendMyself
}

protocol CRDTUseCase {
	func receive(data: Data) async throws -> String
	func insert(at editText: EditText) async throws -> CRDTMessage
	func delete(at editText: EditText) async throws -> CRDTMessage
}

final class DefaultCRDTUseCase {
	private let crdtRepository: CRDTRepository
	private let document: RGASDocument<String> = .init()
	private var merge: RGASMerge<String>
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
		self.merge = .init(doc: document, siteID: 0)
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func receive(data: Data) async throws -> String {
		let response = try JSONDecoder().decode(Node.self, from: data)
		guard response.event != Device.id else {
			throw CRDTUseCaseError.sendMyself
		}
		try response.data.execute(on: merge)
		return document.view()
	}
	
	func insert(at editText: EditText) async throws -> CRDTMessage {
		let operation = createOperation(at: editText, type: .insert, argument: 0)
		let message = try merge.applyLocal(to: operation)
		send(message: message)
		return try await crdtRepository.save(message: message)
	}
	
	func delete(at editText: EditText) async throws -> CRDTMessage {
		let operation = createOperation(at: editText, type: .delete, argument: 1)
		let message = try merge.applyLocal(to: operation)
		send(message: message)
		return try await crdtRepository.save(message: message)
	}
}

private extension DefaultCRDTUseCase {
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
	
	func send(message: CRDTMessage) {
		let node = Node(event: Device.id, data: message)
		guard let data = try? JSONEncoder().encode(node) else {
			return
		}
		WebSocket.shared.send(data: data)
	}
}
