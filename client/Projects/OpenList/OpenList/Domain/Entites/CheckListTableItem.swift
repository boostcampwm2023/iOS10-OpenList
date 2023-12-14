//
//  CheckListTableItem.swift
//  OpenList
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

struct CheckListTableItem: Hashable {
	let id: UUID
	let title: String
	let achievementRate: Double
	
	init(id: UUID = UUID(), title: String, achievementRate: Double) {
		self.id = id
		self.title = title
		self.achievementRate = achievementRate
	}
}
