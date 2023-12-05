//
//  WithCheckListItem.swift
//  OpenList
//
//  Created by Hoon on 12/5/23.
//

import Foundation

protocol ListItem: Codable, Hashable, Identifiable {
	var id: UUID { get }
	var itemId: UUID { get set }
	var title: String { get set }
	var isChecked: Bool { get set }
}

extension ListItem {
	var id: UUID {
		return itemId
	}
}

struct WithCheckListItem: ListItem {
	var itemId: UUID
	var title: String
	var isChecked: Bool
	let name: String?
}
