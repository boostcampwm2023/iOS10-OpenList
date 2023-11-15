//
//  PersistenceUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol PersistenceUseCase {
	func saveCheckList() -> Data
}

final class DefaultPersistenceUseCase {
	private let persistenceRepository: PersistenceRepository
	
	init(persistenceRepository: PersistenceRepository) {
		self.persistenceRepository = persistenceRepository
	}
}

extension DefaultPersistenceUseCase: PersistenceUseCase {
	func saveCheckList() -> Data {
		return persistenceRepository.saveCheckList()
	}
}
