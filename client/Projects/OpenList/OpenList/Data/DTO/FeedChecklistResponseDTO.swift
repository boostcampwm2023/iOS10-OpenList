//
//  FeedCheckListResponseDTO.swift
//  OpenList
//
//  Created by Hoon on 11/30/23.
//

import Foundation

struct FeedCheckListResponseDTO: Decodable {
	let updatedAt: String
	let createdAt: String
	let title: String
	let mainCategory: String
	let subCategory: String
	let minorCategory: String
	let privateChecklistId: Int
	let items: [FeedCheckListItemResponseDTO]
	let feedId: Int
	let likeCount: Int
	let downloadCount: Int
}

struct FeedCheckListItemResponseDTO: Decodable {
	let isChecked: Bool
	let value: String
}
