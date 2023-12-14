//
//  DefaultCRDTStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CoreData
import CRDT
import Foundation

final class DefaultCRDTStorage {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage = .shared) {
		self.coreDataStorage = coreDataStorage
	}
}

extension DefaultCRDTStorage: CRDTStorage {
	func save(message: CRDTMessage) async throws { }
	
	func fetchAll() async throws -> [CRDTMessage] {
		return []
	}
}
