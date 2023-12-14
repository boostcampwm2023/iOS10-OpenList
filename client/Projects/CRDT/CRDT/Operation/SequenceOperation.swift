//
//  SequenceOperation.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public struct SequenceOperation<T: Codable>: LocalOperation {
	public var type: OpType
	public var position: Int
	public var argument: Int
	public var content: [T]
	
	public init(type: OpType, position: Int, argument: Int, content: [T]?) {
		self.type = type
		self.position = position
		self.argument = argument
		self.content = content ?? []
	}
	
	public func clone() -> SequenceOperation {
		return self
	}
}

// MARK: - Static factory methods
extension SequenceOperation {
	static func insert(position: Int, content: T) -> SequenceOperation<T> {
		let contentArray = [content]
		return SequenceOperation(type: .insert, position: position, argument: 0, content: contentArray)
	}
	
	static func delete(position: Int, offset: Int) -> SequenceOperation<T> {
		return SequenceOperation(type: .delete, position: position, argument: offset, content: nil)
	}
	
	static func replace(position: Int, offset: Int, content: T) -> SequenceOperation<T> {
		let contentArray = [content]
		return SequenceOperation(type: .replace, position: position, argument: offset, content: contentArray)
	}
	
	static func update(position: Int, content: T) -> SequenceOperation<T> {
		let contentArray = [content]
		return SequenceOperation(type: .update, position: position, argument: contentArray.count, content: contentArray)
	}
	
	static func move(position: Int, destination: Int, content: T) -> SequenceOperation<T> {
		let contentArray = [content]
		return SequenceOperation(type: .move, position: position, argument: destination, content: contentArray)
	}
	
	static func replace(position: Int, offset: Int, content: [T]) -> SequenceOperation<T> {
		return SequenceOperation(type: .replace, position: position, argument: offset, content: content)
	}
	
	static func noop() -> SequenceOperation<T> {
		return SequenceOperation(type: .noop, position: -1, argument: -1, content: nil)
	}
	
	static func unsupported() -> SequenceOperation<T> {
		return SequenceOperation(type: .unsupported, position: -1, argument: -1, content: nil)
	}
}

extension SequenceOperation {
	mutating func adaptTo(replica: CRDT<T>) throws -> any LocalOperation {
		guard let replica = replica as? MergeAlgorithm else {
			throw CRDTError.inCompatibleType(
				replica,
				.init(debugDescription: "\(#function) : replica is not MergeAlgorithm Type")
			)
		}
		
		let sizeDoc = replica.getDoc().viewLength()
		if type == .insert && position > sizeDoc {
			position = sizeDoc // Adjust the insert position
		} else if type == .delete && sizeDoc == 0 {
			return SequenceOperation(type: .noop, position: 0, argument: 0, content: nil)
		} else if position >= sizeDoc {
			position = max(sizeDoc - 1, 0)
		}
		
		if (type == .delete || type == .update) && position + argument > sizeDoc {
			argument = sizeDoc - position
		}
		
		if (type == .update || type == .move) && position + content.count > sizeDoc {
			content = Array(content.prefix(sizeDoc - position))
		}
		
		return self
	}
	
	// Implementation for contentAsString
	func getContentAsString() -> String {
		return content.map { "\($0)" }.joined()
	}
	
	// Implementation for getLengthOfADel
	func getLengthOfADel() -> Int {
		return argument
	}
	
	func getDestination() -> Int {
		return argument
	}
}
