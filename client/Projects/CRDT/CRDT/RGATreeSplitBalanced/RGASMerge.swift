//
//  RGASMerge.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public final class RGASMerge<T: Codable & Equatable>: MergeAlgorithm<T> {
	private var siteVectorClock: VectorClock
	
	public init(doc: RGASDocument<T>, siteID: Int) {
		self.siteVectorClock = VectorClock()
		super.init(doc: doc, siteId: siteID)
	}
	
	override func integrateRemote(message: any Operation) throws {
		guard let rgaop = message as? (any RGASOperation) else {
			throw CRDTError.typeIsNil(from: message, .init(debugDescription: "\(self) message is not RGASOperation Type"))
		}
		
		guard let rgadoc = getDoc() as? RGASDocument<T> else {
			throw CRDTError.typeIsNil(from: getDoc(), .init(debugDescription: "\(self) rgadoc is not RGASDocument Type"))
		}
		
		if rgaop.type == .insert {
			self.siteVectorClock.increase(rgaop.replica)
		}
		
		try rgadoc.apply(operation: rgaop)
	}
	
	override func localInsert(_ sequenceOperation: SequenceOperation<T>) throws -> [any Operation] {
		var lop = [any Operation]()
		guard let rgadoc = getDoc() as? RGASDocument<T> else {
			throw CRDTError.documentCastFailure(.init(debugDescription: "\(self) getDoc() is not RGADocument Type"))
		}
		
		let position = rgadoc.findPosInLocalTree(position: sequenceOperation.position)
		let s3vpos = position.node?.key
		
		siteVectorClock.increase(getReplicaNumber())
		let s3vtms = RGASS3Vector(sid: getReplicaNumber(), vectorClock: siteVectorClock, offset: 0)
		
		let rgaop = RGASInsertion<T>(
			content: sequenceOperation.content,
			s3vpos: s3vpos,
			s3vtms: s3vtms,
			off1: position.offset
		)
		lop.append(rgaop)
		
		try rgadoc.insert(position: position, content: sequenceOperation.content, s3vtms: s3vtms)
		
		return lop
	}
	
	override func localDelete(_ sequenceOperation: SequenceOperation<T>) throws -> [any Operation] {
		var lop = [any Operation]()
		let rgadoc = try fetchDocument()
		let positionStart = rgadoc.findPosInLocalTree(position: sequenceOperation.position + 1)
		let positionEnd = rgadoc.findPosInLocalTree(
			position: sequenceOperation.position + sequenceOperation.getLengthOfADel()
		)
		
		let node = try fetchNode(position: positionStart)
		let target = positionEnd.node
		let offsetStart = positionStart.offset - 1
		let offsetEnd = positionEnd.offset
		
		if node === target {
			let key = try fetchKey(at: node)
			let rgaop = RGASDeletion<T>(s3vpos: key, off1: offsetStart, off2: offsetEnd)
			try rgadoc.delete(node: node, offset1: offsetStart, offset2: offsetEnd)
			lop.append(rgaop)
		} else {
			let rgaop = try deleteOperation(
				rgaDoc: rgadoc,
				node: node,
				offset1: positionStart.offset - 1
			)
			lop.append(rgaop)
			var nextNode = node.getNextVisible()
			
			while nextNode != nil && !(nextNode === target) {
				let currentNode = try fetchNode(node: nextNode)
				let rgaop = try deleteOperation(
					rgaDoc: rgadoc,
					node: currentNode
				)
				lop.append(rgaop)
				nextNode = currentNode.getNextVisible()
			}
			
			if positionEnd.offset != 0 {
				let nextNode = try fetchNode(node: nextNode)
				let target = try fetchNode(node: target)
				let key = try fetchKey(at: target)
				let rgaop = RGASDeletion<T>(s3vpos: key, off1: 0, off2: offsetEnd)
				try rgadoc.delete(node: nextNode, offset1: 0, offset2: offsetEnd)
				lop.append(rgaop)
			}
		}
		
		return lop
	}
}

private extension RGASMerge {
	func deleteOperation(
		rgaDoc: RGASDocument<T>,
		node: RGASNode<T>,
		offset1: Int = 0
	) throws -> RGASDeletion<T> {
		let key = try fetchKey(at: node)
		let rgaop = RGASDeletion<T>(
			s3vpos: key,
			off1: offset1,
			off2: node.size + node.offset
		)
		try rgaDoc.delete(
			node: node,
			offset1: offset1,
			offset2: node.size + node.offset
		)
		return rgaop
	}
	
	func fetchNode(position: Position<T>) throws -> RGASNode<T> {
		guard let node = position.node else {
			throw CRDTError.typeIsNil(
				from: position.node,
				.init(debugDescription: "position start node is nil")
			)
		}
		return node
	}
	
	func fetchNode(node: RGASNode<T>?) throws -> RGASNode<T> {
		guard let node else {
			throw CRDTError.typeIsNil(
				from: node,
				.init(debugDescription: "node is nil")
			)
		}
		return node
	}
	
	func fetchKey(at node: RGASNode<T>) throws -> RGASS3Vector {
		guard let key = node.key?.clone() else {
			throw CRDTError.typeIsNil(
				from: node.key,
				.init(debugDescription: "node key is nil")
			)
		}
		return key
	}
	
	func fetchDocument() throws -> RGASDocument<T> {
		guard let document = getDoc() as? RGASDocument<T> else {
			throw CRDTError.documentCastFailure(
				.init(debugDescription: "\(getDoc()) is not RGASDocument")
			)
		}
		return document
	}
}
