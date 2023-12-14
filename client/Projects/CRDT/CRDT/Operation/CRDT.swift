//
//  CRDT.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public class CRDT<T> {
	private var replicaNumber: Int
	var nbrCleanMerge: Int
	var nbrRedo: Int
	var nbrInsConcur: Int
	var nbrInsDelConcur: Int
	var nbrDelDelConcur: Int
	
	init(replicaNumber: Int) {
		self.replicaNumber = replicaNumber
		nbrCleanMerge = 0
		nbrRedo = 0
		nbrInsConcur = 0
		nbrInsDelConcur = 0
		nbrDelDelConcur = 0
	}
	
	convenience init() {
		self.init(replicaNumber: 0) // Default replica number or some initial value
	}
	
	final func applyRemote(_ message: CRDTMessage) throws {
		try message.execute(on: self)
	}
	
	func applyOneRemote(_ message: CRDTMessage) throws {
		throw CRDTError.notOverrided(.init(debugDescription: "applyOneRemote(_:) must be overridden"))
	}
	
	func setReplicaNumber(_ replicaNumber: Int) {
		self.replicaNumber = replicaNumber
	}
	
	func getReplicaNumber() -> Int {
		return replicaNumber
	}
	
	func lastExecTime() -> Int64 {
		return 0
	}
}
