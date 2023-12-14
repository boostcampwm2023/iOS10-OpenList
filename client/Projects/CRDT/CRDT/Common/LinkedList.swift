//
//  LinkedList.swift
//  crdt
//
//  Created by wi_seong on 11/18/23.
//

import Foundation

final class LinkedListNode<T> {
	let value: T
	let prev: LinkedListNode<T>?
	let next: LinkedListNode<T>?
	
	init(value: T, prev: LinkedListNode<T>? = nil, next: LinkedListNode<T>? = nil) {
		self.value = value
		self.prev = prev
		self.next = next
	}
}

struct LinkedList<T> {
	let head: LinkedListNode<T>?
	let tail: LinkedListNode<T>?
	
	init(head: LinkedListNode<T>? = nil, tail: LinkedListNode<T>? = nil) {
		self.head = head
		self.tail = tail
	}
	
	func append(value: T) -> LinkedList<T> {
		let newNode = LinkedListNode(value: value)
		guard
			let head = head,
			let tail = tail
		else {
			return LinkedList(head: newNode, tail: newNode)
		}
		
		let newTail = LinkedListNode(value: value, prev: tail, next: newNode)
		let newHead = head
		return LinkedList(head: newHead, tail: newTail)
	}
}
