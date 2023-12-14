//
//  CheckListItem.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

struct CheckListItem: ListItem {
	var id: UUID { itemId	}
	var itemId: UUID
	var title: String
	var isChecked: Bool
}
