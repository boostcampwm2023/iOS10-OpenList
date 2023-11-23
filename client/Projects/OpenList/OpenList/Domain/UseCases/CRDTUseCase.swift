//
//  CRDTUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

protocol CRDTUseCase {
	func receiveData(data: Node) async throws -> String?
	func insert(range: Range<String.Index>) async throws -> CRDTMessage
	func delete(range: Range<String.Index>) async throws -> CRDTMessage
}

final class DefaultCRDTUseCase {
	private let crdtRepository: CRDTRepository
	private let document: RGASDocument<String> = .init()
	private lazy var merge: RGASMerge<String> = .init(doc: document, siteID: 0)
	
	init(crdtRepository: CRDTRepository) {
		self.crdtRepository = crdtRepository
	}
}

extension DefaultCRDTUseCase: CRDTUseCase {
	func receiveData(data: Node) async throws -> String? {
		guard data.id == Device.id else { return nil }
		try data.message.execute(on: merge)
		return document.view()
	}
	
	func insert(range: Range<String.Index>) async throws -> CRDTMessage {
		let operation = createOperation(range: range, type: .insert)
		let message = try merge.applyLocal(to: operation)
		return try await crdtRepository.save(message: message)
	}
	
	func delete(range: Range<String.Index>) async throws -> CRDTMessage {
		let operation = createOperation(range: range, type: .delete)
		let message = try merge.applyLocal(to: operation)
		return try await crdtRepository.save(message: message)
	}
}

private extension DefaultCRDTUseCase {
	func createOperation(
		range: Range<String.Index>,
		type: OpType
	) -> SequenceOperation<String> {
		let operation = SequenceOperation(
			type: type,
			position: 0,
			argument: 1,
			content: [""]
		)
		return operation
	}
}
