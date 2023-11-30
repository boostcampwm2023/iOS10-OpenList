//
//  CheckListStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/16/23.
//

import CoreData
import Foundation

protocol PrivateCheckListStorage {
	func saveCheckList(id: UUID, title: String) async throws
	func fetchAllCheckList() async throws -> [PrivateCheckListResponseDTO]
	func fetchCheckList(id: UUID) async throws -> PrivateCheckListResponseDTO
	func removeCheckList(id: UUID) throws
	func appendCheckListItem(id: UUID, item: CheckListItem) async throws
	func updateCheckListItem(id: UUID, item: CheckListItem) async throws
	func removeCheckListItem(id: UUID, item: CheckListItem, orderBy: [UUID]) async throws
	func transfromToWith(id: UUID) async throws
}
