//
//  CheckListFolderItem.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import Foundation

struct CheckListFolderItem: Hashable {
	private var id: Int { folderId }
	let folderId: Int
	let title: String
	var saveCount: Int = 0
}
