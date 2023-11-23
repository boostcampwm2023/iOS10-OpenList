//
//  CheckListStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/16/23.
//

import CoreData
import Foundation

protocol CheckListStorage {
	func saveCheckList(id: UUID, title: String) async throws
	func fetchAllCheckList() async throws -> [LocalStorageCheckListResponseDTO]
}
