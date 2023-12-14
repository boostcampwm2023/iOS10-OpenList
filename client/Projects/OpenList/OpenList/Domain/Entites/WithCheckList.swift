//
//  WithCheckList.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Foundation

struct WithCheckList: Hashable {
	private var id: UUID { sharedCheckListId }
	let title: String
	let sharedCheckListId: UUID
	let users: [User]
}
