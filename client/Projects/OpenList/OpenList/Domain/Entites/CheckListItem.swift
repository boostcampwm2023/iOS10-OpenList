//
//  CheckListItem.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

// 도메인 모델이 나오면 변경 예정
struct CheckListItem: Codable, Hashable, Identifiable {
	var id: UUID { itemId	}
	let itemId: UUID
	var title: String
	var isChecked: Bool
}
