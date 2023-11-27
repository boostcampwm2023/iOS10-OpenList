//
//  LinkedList.swift
//  OpenList
//
//  Created by wi_seong on 11/24/23.
//

import Foundation

final class LinkedListNode<T: Codable & Equatable>: Codable {
	var value: T
	var next: LinkedListNode<T>?
	
	enum CodingKeys: CodingKey {
		case value, next
	}
	
	init(value: T, next: LinkedListNode<T>? = nil) {
		self.value = value
		self.next = next
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let value = try container.decode(T.self, forKey: .value)
		let next = try container.decode(LinkedListNode<T>?.self, forKey: .next)
		self.value = value
		self.next = next
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(value, forKey: .value)
		try container.encode(next, forKey: .next)
	}
}

final class LinkedList<T: Codable & Equatable> {
	var head: LinkedListNode<T>?
	
	init(head: LinkedListNode<T>? = nil) {
		self.head = head
	}
	
	func append(value: T) {
		if head == nil {
			head = LinkedListNode(value: value)
			return
		}
		
		var node = head
		while node?.next != nil {
			node = node?.next
		}
		node?.next = LinkedListNode(value: value)
	}
	
	func searchNode(from value: T?) -> LinkedListNode<T>? {
		if head == nil { return nil }
		
		var node = head
		while node?.next != nil {
			if node?.value == value { break; }
			node = node?.next
		}
		
		if node?.value != value { return nil }
		return node
	}
}
