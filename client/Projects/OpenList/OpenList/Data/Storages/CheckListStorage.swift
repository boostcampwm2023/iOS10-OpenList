//
//  CheckListStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/16/23.
//

import CoreData
import Foundation

protocol CheckListStorage {
	@discardableResult
	func saveCheckList(id: UUID, title: String) async throws -> LocalStorageCheckListResponseDTO
	func fetchCheckList(id: NSManagedObjectID) async throws -> LocalStorageCheckListResponseDTO
	func fetchAllCheckList() async throws -> [LocalStorageCheckListResponseDTO]
}
