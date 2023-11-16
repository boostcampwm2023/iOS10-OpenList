//
//  DefaultCheckListStorage.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData
import Foundation

final class DefaultCheckListStorage {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage = .shared) {
		self.coreDataStorage = coreDataStorage
	}
}

private extension DefaultCheckListStorage {
	func fetchCheckListFaults() async throws -> [CheckListResponseEntity] {
		return try await coreDataStorage.backgroundViewContext.perform { [weak self] in
			guard let self = self else { throw CoreDataStorageError.selfCapturingError }
			let request: NSFetchRequest<CheckListResponseEntity> = CheckListResponseEntity.fetchRequest()
			return try self.coreDataStorage.backgroundViewContext.fetch(request)
		}
	}
}

extension DefaultCheckListStorage: CheckListStorage {
	func fetchCheckList(id: NSManagedObjectID) async throws -> LocalStorageCheckListResponseDTO {
		do {
			guard
				let object = try coreDataStorage.backgroundViewContext.existingObject(with: id) as? CheckListResponseEntity,
				let id = object.id,
				let title = object.title
			else {
				throw CoreDataStorageError.noData
			}
			return LocalStorageCheckListResponseDTO(coreDataID: object.objectID, id: id, title: title)
		} catch {
			throw CoreDataStorageError.readError(error)
		}
	}
	
	func fetchAllCheckList() async throws -> [LocalStorageCheckListResponseDTO] {
		do {
			let objectIds = try await fetchCheckListFaults().map(\.objectID)
			var result: [LocalStorageCheckListResponseDTO] = []
			for objectId in objectIds {
				let responseDTO = try await fetchCheckList(id: objectId)
				result.append(responseDTO)
			}
			return result
		} catch {
			throw CoreDataStorageError.readError(error)
		}
	}
	
	func saveCheckList(id: UUID, title: String) async throws -> LocalStorageCheckListResponseDTO {
		do {
			let responseDTO = try await coreDataStorage.viewContext.perform { [weak self] in
				guard let self = self else { throw CoreDataStorageError.selfCapturingError }
				let checkList = CheckListResponseEntity(context: coreDataStorage.viewContext)
				checkList.id = id
				checkList.title = title
				try coreDataStorage.viewContext.save()
				return LocalStorageCheckListResponseDTO(coreDataID: checkList.objectID, id: id, title: title)
			}
			return responseDTO
		} catch {
			throw CoreDataStorageError.saveError(error)
		}
	}
}
