//
//  FeedCheckList.swift
//  OpenList
//
//  Created by 김영균 on 12/7/23.
//

import Foundation

struct FeedCheckList: Hashable {
	let createdAt: String
	let title: String
	let items: [FeedCheckListItem]
	let feedId: Int
	let likeCount: Int
	let downloadCount: Int
}

struct FeedCheckListItem: Hashable {
	let isChecked: Bool
	let value: String
}
