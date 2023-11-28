//
//  EditText.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

struct EditText {
	let id: UUID
	let content: String
	let range: NSRange
	
	init(id: UUID = UUID(), content: String, range: NSRange) {
		self.id = id
		self.content = content
		self.range = range
	}
}
