//
//  DefaultPersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class DefaultPersistenceRepository {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage) {
		self.coreDataStorage = coreDataStorage
	}
}

extension DefaultPersistenceRepository: PersistenceRepository {
	func saveCheckList() -> Data {
		return coreDataStorage.save()
	}
}
