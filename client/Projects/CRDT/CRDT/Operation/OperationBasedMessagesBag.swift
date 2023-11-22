//
//  OperationBasedMessagesBag.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

struct OperationBasedMessagesBag {
	private var operations = [OperationBasedOneMessage]()
	
	init() {}
	
	init(_ aThis: OperationBasedMessage, _ msg: OperationBasedMessage) throws {
		try addMessage(aThis)
		try addMessage(msg)
	}
}

private extension OperationBasedMessagesBag {
	mutating func addMessage(_ message: OperationBasedMessage) throws {
		if let bag = message as? OperationBasedMessagesBag {
			operations.append(contentsOf: bag.operations)
		} else if let oneMessage = message as? OperationBasedOneMessage {
			operations.append(oneMessage)
		} else {
			throw CRDTError.inCompatibleType(
				message,
				.init(debugDescription: "\(#function) : message is not OperationBasedMessage type")
			)
		}
	}
}

// MARK: - Encodable
extension OperationBasedMessagesBag: Encodable {
	enum CodingKeys: CodingKey {
		case operations
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(operations, forKey: .operations)
	}
}

// MARK: - Decodable
extension OperationBasedMessagesBag: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		operations = try container.decode([OperationBasedOneMessage].self, forKey: .operations)
	}
}

// MARK: - OperationBasedMessage
extension OperationBasedMessagesBag: OperationBasedMessage {
	func concat(with message: CRDTMessage) throws -> CRDTMessage {
		guard let message = message as? OperationBasedMessage else {
			throw CRDTError.inCompatibleType(
				message,
				.init(debugDescription: "\(#function) : message is not OperationBasedMessage type")
			)
		}
		var ret = OperationBasedMessagesBag()
		try ret.addMessage(self)
		try ret.addMessage(message)
		return ret
	}
	
	func clone() throws -> CRDTMessage {
		var clone = OperationBasedMessagesBag()
		for operation in operations {
			guard let operation = operation.clone() as? OperationBasedOneMessage else {
				throw CRDTError.inCompatibleType(
					operation.clone(),
					.init(debugDescription: "\(#function): opertion.clone() is not OperationBasedOneMessage type")
				)
			}
			clone.operations.append(operation)
		}
		return clone
	}
	
	func execute<T>(on crdt: CRDT<T>) throws {
		for operation in operations {
			try crdt.applyOneRemote(operation)
		}
	}
	
	func size() -> Int {
		return operations.count
	}
}

// MARK: - CustomDebugStringConvertible
extension OperationBasedMessagesBag: CustomDebugStringConvertible {
	var debugDescription: String {
		var s = "BAG:"
		for m in operations {
			s += " + \(m)"
		}
		return s
	}
}
