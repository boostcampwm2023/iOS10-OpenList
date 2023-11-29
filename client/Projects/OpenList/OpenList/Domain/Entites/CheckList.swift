//
//  CheckList.swift
//  OpenList
//
//  Created by wi_seong on 11/27/23.
//

import Foundation

struct CheckList {
	let id: UUID
	let title: String
	let createdAt: Date
	let updatedAt: Date
	let progress: Int
	let orderBy: [UUID]
	var items: [CheckListItem]
}
