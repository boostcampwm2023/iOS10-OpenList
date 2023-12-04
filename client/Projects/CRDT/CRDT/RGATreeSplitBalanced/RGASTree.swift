//
//  RGASTree.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

/// Identifier Data Sturcture로 가중 이진 트리이다.
/// 논문에서는 idNode라고 부른다.
/// 가중 트리는 일련의 구조화된 idNodes을 가지고 있다.
public final class RGASTree<T: Codable & Equatable>: Codable {
	/// 기본 RGA알고리즘의 링크드 리스트의 노드
	/// 기본 RGA 노드도 RGASTree을 서로 참조하고 있다.
	/// 만약 RGA 노드가 툼스톤이 된다면 nil을 가르킨다.
	weak var root: RGASNode<T>? //
	
	/// 부모를 가르키는 idNode
	var parent: RGASTree<T>?
	
	/// 왼쪽 자식 트리를 가르키는 idNode
	private(set) var leftChild: RGASTree<T>?
	
	/// 오른쪽 자식 트리를 가르키는 idNode
	private(set) var rightChild: RGASTree<T>?
	
	/// 트리의 총 크기(서브 트리의 가중치 합)
	/// size 값을 사용해서 주어진 위치에 있는 노드를 찾을 수 있다.
	var size: Int
	
	// Constructors
	public init() {
		root = nil
		leftChild = nil
		rightChild = nil
		size = 0
	}
	
	public init(
		root: RGASNode<T>?,
		leftChild: RGASTree<T>?,
		rightChild: RGASTree<T>?,
		parent: RGASTree<T>?,
		size: Int
	) {
		self.root = root
		self.leftChild = leftChild
		self.rightChild = rightChild
		self.parent = parent
		self.size = size
		self.root?.tree = self
	}
	
	convenience init(root: RGASNode<T>?, leftChild: RGASTree<T>?, rightChild: RGASTree<T>?) {
		let leftSize = leftChild?.size ?? 0
		let rightSize = rightChild?.size ?? 0
		let rootSize = root?.size ?? 0
		self.init(
			root: root,
			leftChild: leftChild,
			rightChild: rightChild,
			parent: nil,
			size: leftSize + rightSize + rootSize
		)
	}
	
	func clone() -> RGASTree {
		return RGASTree(root: root, leftChild: leftChild, rightChild: rightChild, parent: parent, size: size)
	}
}

// Getters & Setters
extension RGASTree {
	func getRootSize() -> Int {
		return (root?.isVisible ?? false) ? root!.size : 0
	}
	
	func setRoot(_ node: RGASNode<T>?) {
		self.root = node
	}
	
	func getparent() -> RGASTree? {
		return parent
	}
	
	func setparent(_ tree: RGASTree<T>?) {
		self.parent = tree
	}
	
	func getleftChild() -> RGASTree? {
		return leftChild
	}
	
	func setleftChild(_ tree: RGASTree<T>?) {
		self.leftChild = tree
		
		if leftChild != nil {
			self.leftChild?.setparent(self)
		}
	}
	
	func getrightChild() -> RGASTree? {
		return rightChild
	}
	
	func setrightChild(_ tree: RGASTree<T>?) {
		self.rightChild = tree
		
		if rightChild != nil {
			self.rightChild?.setparent(self)
		}
	}
	
	func getSize() -> Int {
		return size
	}
	
	func setSize(_ newSize: Int) {
		self.size = newSize
	}
	
	func getRightSize() -> Int {
		return rightChild?.size ?? 0
	}
	
	func getLeftSize() -> Int {
		return leftChild?.size ?? 0
	}
}
