//
//  OperationBasedOneMessage.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public struct OperationBasedOneMessage {
	var operation: any Operation
}

// MARK: - Encodable
extension OperationBasedOneMessage: Encodable {
	enum CodingKeys: CodingKey {
		case operation
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if let operation = operation as? RGASInsertion<String> {
			try container.encode(operation, forKey: .operation)
		} else if let operation = operation as? RGASDeletion<String> {
			try container.encode(operation, forKey: .operation)
		} else {
			throw EncodingError.invalidValue(
				operation,
				EncodingError.Context(
					codingPath: [CodingKeys.operation],
					debugDescription: "Unknown Operation type"
				)
			)
		}
	}
}

// MARK: - OperationBasedMessage
extension OperationBasedOneMessage: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let operation = try? container.decode(RGASInsertion<String>.self, forKey: .operation) {
			self.operation = operation
		} else if let operation = try? container.decode(RGASDeletion<String>.self, forKey: .operation) {
			self.operation = operation
		} else {
			throw DecodingError.dataCorruptedError(
				forKey: .operation,
				in: container,
				debugDescription: "Unknown CRDTMessage type"
			)
		}
	}
}

// MARK: - OperationBasedMessage
extension OperationBasedOneMessage: OperationBasedMessage {
	public func concat(with message: CRDTMessage) throws -> CRDTMessage {
		guard let message = message as? OperationBasedMessage else {
			throw CRDTError.inCompatibleType(
				message,
				.init(debugDescription: "\(#function) : message is not OperationBasedMessage type")
			)
		}
		return try OperationBasedMessagesBag(self, message)
	}
	
	public func clone() -> CRDTMessage {
		return OperationBasedOneMessage(operation: operation.clone())
	}
	
	public func size() -> Int {
		return 1
	}
	
	public func execute<T>(on crdt: CRDT<T>) throws {
		try crdt.applyOneRemote(self)
	}
}

// MARK: - CustomDebugStringConvertible
extension OperationBasedOneMessage: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "OperationBasedOneMessage{operation=\(operation)}"
	}
}
