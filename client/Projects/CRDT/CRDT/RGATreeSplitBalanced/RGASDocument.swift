//
//  RGASDocument.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public final class RGASDocument<T: Codable & Equatable> {
	private var hash: [RGASS3Vector?: RGASNode<T>] = [:]
	private(set) var head: RGASNode<T>
	private(set) public var root: RGASTree<T>?
	private var size = 0
	private var nodeNumberInTree = 0
	private var tombstoneNumber = 0
	private var nbIns = 0
	
	public init() {
		head = RGASNode()
		hash[nil] = head
	}
}

// MARK: Document
extension RGASDocument: Document {
	public func view() -> String {
		// Return the string representation of the document
		var result = ""
		treeView(buf: &result, tree: root)
		return result
	}
	
	public func viewLength() -> Int {
		return size
	}
	
	public func apply(operation: any Operation) throws {
		guard let rgaOperation = operation as? (any RGASOperation) else {
			throw CRDTError.downCast(
				from: operation,
				.init(debugDescription: "\(self) operaion is not RGASOperation")
			)
		}
		switch rgaOperation.type {
		case .delete:
			try deleteOperation(rgaOperation: rgaOperation)
		case .insert:
			try insertOperation(rgaOperation: rgaOperation)
		default:
			throw CRDTError.downCast(
				from: rgaOperation,
				.init(debugDescription: "\(self) rgaOperation is not RGASInsertion")
			)
		}
	}
}

// MARK: View
extension RGASDocument {
	public func viewWithSeparator() -> String {
		var string = ""
		var node = head.next
		
		while let currentNode = node {
			if currentNode.isVisible, let content = currentNode.content {
				let node = content.map { String(describing: $0) }.joined()
				string += "->|\(node)|"
			}
			node = currentNode.next
		}
		return string
	}
	
	func treeView(buf: inout String, tree: RGASTree<T>?) {
		if let leftChild = tree?.getleftChild() {
			treeView(buf: &buf, tree: leftChild)
		}
		
		buf += (tree?.root?.getContentAsString()) ?? ""
		
		if let rightChild = tree?.getrightChild() {
			treeView(buf: &buf, tree: rightChild)
		}
	}
	
	public func treeViewWithSeparator(tree: RGASTree<T>?, depth: Int) -> String {
		guard let tree else { return "" }
		
		var result = ""
		
		if let leftChild = tree.getleftChild() {
			result += treeViewWithSeparator(tree: leftChild, depth: depth + 1)
		}
		
		let indent = String(repeating: "   ", count: depth)
		result += "\(indent)-->\(tree.root?.getContentAsString() ?? ""), \(tree.size)\n"
		
		if let rightChild = tree.getrightChild() {
			result += treeViewWithSeparator(tree: rightChild, depth: depth + 1)
		}
		
		return result
	}
}

// MARK: Common
extension RGASDocument {
	// MARK: Find
	func getPosition(node: RGASNode<T>, start: Int) -> Position<T> {
		var size = node.size
		var currentNode: RGASNode<T>? = node
		
		while let unwrappedNode = currentNode, size <= start {
			currentNode = unwrappedNode.getNextVisible()
			if let nextNode = currentNode {
				size += nextNode.size
			}
		}
		
		guard let foundNode = currentNode else {
			return Position(offset: 0)
		}
		return Position(node: foundNode, offset: foundNode.size - size + start)
	}
	
	func findPosInLocalTree(position: Int) -> Position<T> {
		guard
			var tree = root,
			position > 0 else {
			return Position(node: head, offset: 0)
		}
		var localPosition = position
		
		while
			!(tree.getLeftSize() < localPosition &&
				localPosition <= tree.getLeftSize() + tree.getRootSize())
		{
			if localPosition <= tree.getLeftSize() {
				guard let leftChild = tree.leftChild else { break }
				tree = leftChild
			} else {
				localPosition -= tree.getLeftSize() + tree.getRootSize()
				guard let rightChild = tree.rightChild else { break }
				tree = rightChild
			}
		}
		
		guard let rootOffset = tree.root?.offset else {
			return Position(node: head, offset: 0)
		}
		
		return Position(
			node: tree.root,
			offset: localPosition + rootOffset - tree.getLeftSize()
		)
	}
	
	func findGoodNode(s3vpos: RGASS3Vector?, offset: Int) -> RGASNode<T>? {
		var target = hash[s3vpos]
		while
			let currentTarget = target,
			currentTarget.offset + currentTarget.size < offset
		{
			target = currentTarget.link
		}
		return target
	}
	
	func findMostRight(tree: RGASTree<T>, increment: Int) -> RGASTree<T> {
		var currentTree = tree
		
		while let rightChild = currentTree.getrightChild() {
			currentTree.setSize(currentTree.size + increment)
			currentTree = rightChild
		}
		
		currentTree.setSize(currentTree.size + increment)
		return currentTree
	}
	
	func findMostLeft(tree: RGASTree<T>, increment: Int) -> RGASTree<T> {
		var currentTree = tree
		
		while let leftChild = currentTree.getleftChild() {
			currentTree.setSize(currentTree.size + increment)
			currentTree = leftChild
		}
		
		currentTree.setSize(currentTree.size + increment)
		return currentTree
	}
	
	// MARK: Remote
	@discardableResult
	func remoteSplit(node: RGASNode<T>, offsetAbs: Int) -> RGASNode<T>? {
		var end: RGASNode<T>?
		if offsetAbs - node.offset > 0 && node.size - offsetAbs + node.offset > 0 {
			var contentA: [T]?
			var contentB: [T]?
			
			if node.isVisible {
				let content = node.content
				contentA = Array(content?[0..<max(0, offsetAbs - node.offset)] ?? [])
				contentB = Array(content?[max(0, offsetAbs - node.offset)..<node.size] ?? [])
			}
			
			end = RGASNode(node: node.clone(), content: contentB, offset: offsetAbs)
			end?.size = node.size - offsetAbs + node.offset
			end?.next = node.getNextVisible()
			
			node.content = contentA
			node.size = offsetAbs - node.offset
			node.next = end
			node.link = end
			
			hash[node.key] = node
			hash[end?.key] = end  // Assuming a default value for RgaSS3Vector
			
			if node.isVisible {
				let treeEnd = RGASTree(root: end, leftChild: nil, rightChild: node.tree?.getrightChild())
				node.tree?.setRoot(node)
				node.tree?.setrightChild(treeEnd)
				
				nodeNumberInTree += 1
			}
		}
		return node.link
	}
}

// MARK: Insert
extension RGASDocument {
	func insertOperation(rgaOperation: any RGASOperation) throws {
		nbIns += 1
		guard let insertionOperation = rgaOperation as? RGASInsertion<T> else {
			throw CRDTError.downCast(
				from: rgaOperation,
				.init(debugDescription: "\(self) rgaOperation is not RGASInsertion")
			)
		}
		try update(operation: insertionOperation)
		balanceTree()
	}
	
	func insert(position: Position<T>, content: [T], s3vtms: RGASS3Vector) throws {
		guard let node = position.node else {
			throw CRDTError.typeIsNil(
				from: position.node,
				.init(debugDescription: "\(self) position.node is nil")
			)
		}
		let newnd = RGASNode(s3v: s3vtms, content: content)
		let offset = position.offset
		
		remoteSplit(node: node, offsetAbs: offset)
		let nodeTree = node.getNextVisible()
		insertInLocalTree(nodePos: nodeTree, newnd: newnd)
		newnd.next = node.getNextVisible()
		node.next = newnd
		hash[s3vtms] = newnd
		size += newnd.size
	}
	
	func insertInLocalTree(nodePos: RGASNode<T>?, newnd: RGASNode<T>) {
		let tree = nodePos?.tree
		let newTree = RGASTree(root: newnd, leftChild: nil, rightChild: nil)
		
		guard let root else {
			root = newTree
			insertTree(to: newTree, size: newnd.size)
			return
		}
		
		guard nodePos != nil else {
			findMostRight(tree: root, increment: 0).setrightChild(newTree)
			insertTree(to: newTree, size: newnd.size)
			return
		}
		
		guard let treeLeftChild = tree?.getleftChild() else {
			tree?.setleftChild(newTree)
			insertTree(to: newTree, size: newnd.size)
			return
		}
		
		findMostRight(tree: treeLeftChild, increment: 0).setrightChild(newTree)
		
		insertTree(to: newTree, size: newnd.size)
	}
	
	func insertTree(to tree: RGASTree<T>, size: Int) {
		var currentTree = tree
		while let parent = currentTree.getparent() {
			currentTree = parent
			currentTree.setSize(currentTree.size + size)
		}
		nodeNumberInTree += 1
	}
}

// MARK: Delete
extension RGASDocument {
	func deleteOperation(rgaOperation: any RGASOperation) throws {
		guard let deletionOperation = rgaOperation as? RGASDeletion<T> else {
			throw CRDTError.downCast(
				from: rgaOperation,
				.init(debugDescription: "\(self) rgaOperation is not RGASDeletion")
			)
		}
		try remove(operation: deletionOperation)
	}
	
	func remove(operation: RGASDeletion<T>) throws {
		guard var node = findGoodNode(s3vpos: operation.s3vpos, offset: operation.offset1) else {
			throw CRDTError.typeIsNil(
				from: operation,
				.init(debugDescription: "\(self) find not node")
			)
		}
		
		if operation.offset1 > node.offset {
			guard let spliteNode = remoteSplit(node: node, offsetAbs: operation.offset1) else {
				throw CRDTError.typeIsNil(
					from: node,
					.init(debugDescription: "\(self) remote split it fail")
				)
			}
			node = spliteNode
		}
		
		while node.offset + node.size < operation.offset2 {
			if node.isVisible {
				size -= node.size
				tombstoneNumber += 1
				try deleteInLocalTree(node: node)
				node.makeTombstone()
			}
			guard let linkNode = node.link else {
				throw CRDTError.typeIsNil(
					from: node.link,
					.init(debugDescription: "\(self) node link is nil")
				)
			}
			node = linkNode
		}
		
		guard operation.offset2 > node.offset else {
			return
		}
		remoteSplit(node: node, offsetAbs: operation.offset2)
		guard node.isVisible else { return }
		size -= node.size
		try deleteInLocalTree(node: node)
		tombstoneNumber += 1
		node.makeTombstone()
	}
	
	func delete(node: RGASNode<T>, offset1: Int, offset2: Int) throws {
		var currentNode = node
		if
			offset1 > currentNode.offset,
			let splitNode = remoteSplit(node: currentNode, offsetAbs: offset1)
		{
			currentNode = splitNode
		}
		if offset2 > currentNode.offset {
			remoteSplit(node: currentNode, offsetAbs: offset2)
		}
		
		size -= currentNode.size
		tombstoneNumber += 1
		try deleteInLocalTree(node: currentNode)
		currentNode.makeTombstone()
	}
	
	func deleteInLocalTree(node: RGASNode<T>) throws {
		guard let tree = node.tree else {
			throw CRDTError.typeIsNil(
				from: node.tree,
				.init(debugDescription: "\(String(describing: node.tree)) is nil")
			)
		}
		let isRoot = tree === root
		let hasrightChild = tree.getrightChild() != nil
		let hasleftChild = tree.getleftChild() != nil
		let isLeaf = !hasrightChild && !hasleftChild
		var isleftChild = false
		
		var parent: RGASTree<T>?
		if !isRoot {
			parent = tree.getparent()
			if let parent, parent.getleftChild() === tree {
				isleftChild = true
			}
		}
		
		if isRoot {
			if isLeaf {
				root = nil
			} else if hasleftChild && !hasrightChild {
				root = root!.getleftChild()
			} else if !hasleftChild && hasrightChild {
				root = root!.getrightChild()
			} else if let rightChild = tree.getrightChild() {
				let tree2 = findMostLeft(tree: rightChild, increment: root?.getleftChild()?.size ?? 0)
				tree2.setleftChild(root?.getleftChild())
				root = rightChild
			} else {
				throw CRDTError.typeIsNil(
					from: tree.getrightChild(),
					.init(debugDescription: "\(String(describing: tree.getrightChild())) is nil")
				)
			}
		} else if isLeaf {
			if isleftChild {
				parent!.setleftChild(nil)
			} else {
				parent!.setrightChild(nil)
			}
		} else {
			if !hasrightChild {
				if isleftChild {
					parent!.setleftChild(tree.getleftChild())
				} else {
					parent!.setrightChild(tree.getleftChild())
				}
			} else if !hasleftChild {
				if isleftChild {
					parent!.setleftChild(tree.getrightChild())
				} else {
					parent!.setrightChild(tree.getrightChild())
				}
			} else if let rightChild = tree.getrightChild() {
				let tree2 = findMostLeft(tree: rightChild, increment: tree.getleftChild()!.size)
				tree2.setleftChild(tree.getleftChild())
				if isleftChild {
					parent!.setleftChild(rightChild)
				} else {
					parent!.setrightChild(rightChild)
				}
			} else {
				throw CRDTError.typeIsNil(
					from: tree.getrightChild(),
					.init(debugDescription: "\(String(describing: tree.getrightChild())) is nil")
				)
			}
		}
		
		node.tree = nil
		nodeNumberInTree -= 1
		
		while parent != nil {
			parent!.setSize(parent!.size - node.size)
			parent = parent!.parent
		}
	}
}

// MARK: Update
extension RGASDocument {
	func update(operation: RGASInsertion<T>) throws {
		guard var node = findGoodNode(s3vpos: operation.s3vpos, offset: operation.offset1) else {
			throw CRDTError.typeIsNil(
				from: findGoodNode(s3vpos: operation.s3vpos, offset: operation.offset1),
				.init(debugDescription: "\(self) findGoodNode is nil")
			)
		}
		let newnd = RGASNode(s3v: operation.s3vtms, content: operation.content)
		
		if operation.offset1 > node.offset {
			remoteSplit(node: node, offsetAbs: operation.offset1)
		}
		
		node = handleConcurrence(node: node, s3v: operation.s3vtms)
		let nodeTree = node.getNextVisible()
		insertInLocalTree(nodePos: nodeTree, newnd: newnd)
		newnd.next = node.getNextVisible()
		node.next = newnd
		hash[operation.s3vtms] = newnd
		size += newnd.size
	}
	
	func handleConcurrence(node: RGASNode<T>, s3v: RGASS3Vector) -> RGASNode<T> {
		var currentNode = node
		while let nextNode = currentNode.next {
			if
				let key = nextNode.key,
				s3v > key
			{
				break
			}
			currentNode = nextNode
		}
		return currentNode
	}
}

// MARK: Balance
extension RGASDocument {
	func balanceTree() {
		if (
			nodeNumberInTree > 3000 &&
			nbIns > Int(Double(nodeNumberInTree) / (0.14 * log(Double(nodeNumberInTree)) / log(2)))
		) {
			nbIns = 0
			let content = createNodeList(tree: root)
			createBalancedTree(tree: RGASTree<T>(), content: content, begin: 0, length: content.count)
			addGoodSize(tree: root)
		}
	}
	
	func createNodeList(tree: RGASTree<T>?) -> [RGASNode<T>] {
		guard let tree = tree else {
			return []
		}
		
		var list = [RGASNode<T>]()
		
		if let leftChild = tree.getleftChild() {
			list += createNodeList(tree: leftChild)
		}
		
		if let rootNode = tree.root {
			list.append(rootNode)
		}
		
		if let rightChild = tree.getrightChild() {
			list += createNodeList(tree: rightChild)
		}
		
		tree.root?.tree = nil
		return list
	}
	
	func createBalancedTree(tree: RGASTree<T>, content: [RGASNode<T>], begin: Int, length: Int) {
		guard !content.isEmpty else { return }
		
		let leftSubtree = (length - 1) / 2
		let rightSubtree = length - 1 - leftSubtree
		
		if leftSubtree > 0 {
			let leftChildren = RGASTree<T>()
			tree.setleftChild(leftChildren)
			createBalancedTree(tree: leftChildren, content: content, begin: begin, length: leftSubtree)
		}
		
		if begin + leftSubtree < content.count {
			let node = content[begin + leftSubtree]
			node.tree = tree
			tree.setRoot(node)
			tree.setSize(0)
		}
		
		if rightSubtree > 0 {
			let rightChildren = RGASTree<T>()
			tree.setrightChild(rightChildren)
			createBalancedTree(tree: rightChildren, content: content, begin: begin + leftSubtree + 1, length: rightSubtree)
		}
		
		root = tree
	}
	
	func addGoodSize(tree: RGASTree<T>?) {
		guard let tree = tree else { return }
		
		if let leftChild = tree.getleftChild() {
			addGoodSize(tree: leftChild)
			tree.setSize(tree.size + leftChild.size)
		}
		
		tree.setSize(tree.size + tree.getRootSize())
		
		if let rightChild = tree.getrightChild() {
			addGoodSize(tree: rightChild)
			tree.setSize(tree.size + rightChild.size)
		}
	}
}
