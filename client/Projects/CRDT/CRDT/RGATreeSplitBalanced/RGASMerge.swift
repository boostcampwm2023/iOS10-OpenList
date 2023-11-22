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
		guard let rgadoc = getDoc() as? RGASDocument<T> else {
			throw CRDTError.documentCastFailure(.init(debugDescription: "\(self) getDoc() is not RGADocument Type"))
		}
		
		let positionStart = rgadoc.findPosInLocalTree(position: sequenceOperation.position + 1)
		let positionEnd = rgadoc.findPosInLocalTree(
			position: sequenceOperation.position + sequenceOperation.getLengthOfADel()
		)
		
		var lop = [any Operation]()
		var node = positionStart.node
		let target = positionEnd.node
		
		let offsetStart = positionStart.offset - 1
		let offsetEnd = positionEnd.offset
		
		while node != nil && !(node === target) {
			guard let nodeKey = node?.key?.clone() else {
				throw CRDTError.typeIsNil(from: node?.key?.clone(), .init(debugDescription: "\(self) nodeKey is nil"))
			}
			
			let rgaop = RGASDeletion<T>(s3vpos: nodeKey, off1: offsetStart, off2: offsetEnd)
			rgadoc.delete(node: node!, offset1: offsetStart, offset2: offsetEnd)
			lop.append(rgaop)
			node = node?.getNextVisible()
		}
		
		if let target = target, positionEnd.offset != 0 {
			guard let targetKey = target.key?.clone() else {
				throw CRDTError.typeIsNil(from: target.key?.clone(), .init(debugDescription: "\(self) targetKey is nil"))
			}
			
			let rgaop = RGASDeletion<T>(s3vpos: targetKey, off1: 0, off2: offsetEnd)
			rgadoc.delete(node: target, offset1: 0, offset2: offsetEnd)
			lop.append(rgaop)
		}
		
		return lop
	}
}
