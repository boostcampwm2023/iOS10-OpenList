//
//  TextChange.swift
//  OpenList
//
//  Created by wi_seong on 12/3/23.
//

import Foundation

struct TextChange {
	let id: UUID
	let range: NSRange
	let oldString: String
	let replacementString: String
	
	init(
		id: UUID = UUID(),
		range: NSRange = .init(location: 0, length: 0),
		oldString: String = "",
		replacementString: String = ""
	) {
		self.id = id
		self.range = range
		self.oldString = oldString
		self.replacementString = replacementString
	}
}
