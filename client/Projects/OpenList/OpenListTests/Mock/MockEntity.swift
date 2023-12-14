//
//  MockEntity.swift
//  OpenListTests
//
//  Created by wi_seong on 11/16/23.
//

import Foundation

struct MockEntity {
	let id: UUID
	let title: String
	
	init(id: UUID = UUID(), title: String) {
		self.id = id
		self.title = title
	}
}
