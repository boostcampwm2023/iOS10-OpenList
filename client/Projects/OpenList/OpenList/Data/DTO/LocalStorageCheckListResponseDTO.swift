//
//  LocalStorageCheckListResponseDTO.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData

struct LocalStorageCheckListResponseDTO {
	let coreDataID: NSManagedObjectID
	let id: UUID
	let title: String
}
