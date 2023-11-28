//
//  PrivateCheckListResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData

struct PrivateCheckListResponseDTO {
	let checklistId: UUID
	let createdAt: Date
	let updatedAt: Date
	let title: String
	let progress: Int
	var items: [PrivateCheckListItemResponseDTO]
}

struct PrivateCheckListItemResponseDTO {
	let itemId: UUID
	let content: String
	let createdAt: Date
	let isChecked: Bool
	let index: Int32
}
