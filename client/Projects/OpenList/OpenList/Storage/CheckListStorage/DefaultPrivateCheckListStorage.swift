//
//  DefaultPrivateCheckListStorage.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData
import Foundation

final class DefaultPrivateCheckListStorage {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage = .shared) {
		self.coreDataStorage = coreDataStorage
	}
}

private extension DefaultPrivateCheckListStorage {
	func fetchAllCheckListFault() async throws -> [PrivateCheckListEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task { [weak self] in
				guard let self else { return }
				let request: NSFetchRequest<PrivateCheckListEntity> = PrivateCheckListEntity.fetchRequest()
				let checkListFaults = try coreDataStorage.backgroundViewContext.fetch(request)
				continuation.resume(returning: checkListFaults)
			}
		}
	}
	
	func fetchCheckListFault(id: UUID) async throws -> [PrivateCheckListEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task { [weak self] in
				guard let self else { return }
				let request: NSFetchRequest<PrivateCheckListEntity> = PrivateCheckListEntity.fetchRequest()
				request.predicate = NSPredicate(
					format: "%K == %@",
					#keyPath(PrivateCheckListEntity.checklistId),
					id as CVarArg
				)
				let checkListFaults = try coreDataStorage.backgroundViewContext.fetch(request)
				continuation.resume(returning: checkListFaults)
			}
		}
	}
	
	func fetchEntity<T>(by id: NSManagedObjectID, type: T.Type) throws -> T {
		guard let entity = try coreDataStorage.viewContext.existingObject(with: id) as? T else {
			throw CoreDataStorageError.noData
		}
		return entity
	}
}

extension DefaultPrivateCheckListStorage: PrivateCheckListStorage {
	func fetchAllCheckList() async throws -> [PrivateCheckListResponseDTO] {
		return try await fetchAllCheckListFault()
			.map(\.objectID)
			.map { try fetchEntity(by: $0, type: PrivateCheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
	}
	
	func fetchCheckList(id: UUID) async throws -> PrivateCheckListResponseDTO {
		let response = try await fetchCheckListFault(id: id)
			.map(\.objectID)
			.map { try fetchEntity(by: $0, type: PrivateCheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
			.first
		guard let response else {
			throw CoreDataStorageError.noData
		}
		return response
	}
	
	func saveCheckList(id: UUID, title: String) async throws {
		Task { [weak self] in
			guard let self else { return }
			let backgroundContext = coreDataStorage.backgroundViewContext
			let checkList = PrivateCheckListEntity(context: backgroundContext)
			checkList.makeInitialCheckListEntity(title: title)
			do {
				try backgroundContext.save()
				return
			} catch {
				throw CoreDataStorageError.saveError(error)
			}
		}
	}
}

private extension DefaultPrivateCheckListStorage {
	func mapToLocalStorageCheckListResponseDTO(
		_ entity: PrivateCheckListEntity
	) throws -> PrivateCheckListResponseDTO {
		guard
			let checklistId = entity.checklistId,
			let title = entity.title,
			let createdAt = entity.createdAt,
			let updatedAt = entity.updatedAt,
			let itemEntities = entity.itemId as? Set<PrivateCheckListItemEntity>
		else {
			throw CoreDataStorageError.unwrapError
		}
		
		let items = try itemEntities.compactMap(mapToCheckListItemResponseDTO(_:))
		
		return PrivateCheckListResponseDTO(
			checklistId: checklistId,
			createdAt: createdAt,
			updatedAt: updatedAt,
			title: title,
			progress: Int(entity.progress),
			items: items
		)
	}
	
	func mapToCheckListItemResponseDTO(
		_ entity: PrivateCheckListItemEntity
	) throws -> PrivateCheckListItemResponseDTO {
		guard
			let itemId = entity.itemId,
			let content = entity.content,
			let createdAt = entity.createdAt
		else {
			throw CoreDataStorageError.unwrapError
		}
		return PrivateCheckListItemResponseDTO(
			itemId: itemId,
			content: content,
			createdAt: createdAt,
			isChecked: entity.isChecked
		)
	}
}

private extension PrivateCheckListEntity {
	func makeInitialCheckListEntity(title: String) {
		self.checklistId = UUID()
		self.title = title
		self.progress = 0
		self.createdAt = .now
		self.updatedAt = .now
		self.itemId = nil
	}
}

private extension PrivateCheckListItemEntity {
	func makeInitialCheckListItemEntity(
		content: String,
		isChecked: Bool
	) {
		self.itemId = UUID()
		self.content = content
		self.isChecked = isChecked
		self.createdAt = .now
	}
}
