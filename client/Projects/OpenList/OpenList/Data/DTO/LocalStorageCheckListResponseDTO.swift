//
//  LocalStorageCheckListResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData

struct LocalStorageCheckListResponseDTO {
	let checklistId: UUID
	let createdAt: Date
	let updatedAt: Date
	let title: String
	let progress: Int
	var items: [LocalStorageCheckListItemResponseDTO]
}

struct LocalStorageCheckListItemResponseDTO {
	let itemId: UUID
	let content: String
	let createdAt: Date
	let isChecked: Bool
}
