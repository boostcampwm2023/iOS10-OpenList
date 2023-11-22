//
//  MergeAlgorithm.swift
//  crdt
//
//  Created by wi_seong on 11/20/23.
//

import Foundation

public class MergeAlgorithm<T: Codable>: CRDT<T> {
	private let doc: Document
	private var states: [String] = []
	
	public init(doc: Document, siteId: Int) {
		self.doc = doc
		super.init(replicaNumber: siteId)
	}
	
	// This method should be overridden in subclasses.
	func integrateRemote(message: any Operation) throws {
		fatalError("integrateRemote(message:) must be overridden")
	}
	
	func getDoc() -> Document {
		return doc
	}
	
	func reset() {
		// Implement reset logic if needed.
	}
	
	public func applyLocal(to sequenceOperation: SequenceOperation<T>) throws -> CRDTMessage {
		guard let messages = try? oldApplyLocal(sequenceOperation) else {
			throw CRDTError.typeIsNil(
				from: sequenceOperation,
				.init(debugDescription: "\(self) sequenceOperation is nil")
			)
		}
		
		var crdtMessage: CRDTMessage?
		for message in messages {
			if crdtMessage == nil {
				crdtMessage = OperationBasedOneMessage(operation: message)
			} else {
				crdtMessage = try crdtMessage?.concat(with: OperationBasedOneMessage(operation: message))
			}
		}
		
		guard let crdtMessage else {
			throw CRDTError.typeIsNil(
				from: sequenceOperation,
				.init(debugDescription: "\(self) sequenceOperation is nil")
			)
		}
		return crdtMessage
	}
	
	private func oldApplyLocal(_ opt: SequenceOperation<T>) throws -> [any Operation]? {
		// Convert SequenceOperation to a list of CRDT operations
		switch opt.type {
		case .insert:
			return try localInsert(opt)
		case .delete:
			return try localDelete(opt)
//		case .replace:
//			return try localReplace(opt)
//		case .update:
//			return try localUpdate(opt)
//		case .move:
//			return try localMove(opt)
		case .noop:
			return nil
		default:
			return nil  // or throw IncorrectTraceException
		}
	}
	
	override func applyOneRemote(_ mess: CRDTMessage) throws {
		try integrateRemote(message: MergeAlgorithm<T>.CRDTMessage2SequenceMessage(mess))
	}
	
	static func CRDTMessage2SequenceMessage(_ message: CRDTMessage) throws -> any Operation {
		// Convert CRDTMessage to SequenceMessage
		// Implement conversion logic.
		guard let operationBasedOneMessage = message as? OperationBasedOneMessage else {
			throw CRDTError.downCast(
				from: message,
				.init(debugDescription: "\(self) message is not OperationBasedOneMessage")
			)
		}
		return operationBasedOneMessage.operation
	}
	
	var lookup: String {
		return doc.view()
	}
	
	// Abstract methods
	func localInsert(_ opt: SequenceOperation<T>) throws -> [any Operation] {
		fatalError("localInsert(opt:) must be overridden")
	}
	
	func localDelete(_ opt: SequenceOperation<T>) throws -> [any Operation] {
		fatalError("localDelete(opt:) must be overridden")
	}
}
