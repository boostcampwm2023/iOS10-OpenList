//
//  WithCheckListItemDetail.swift
//  OpenList
//
//  Created by Hoon on 12/7/23.
//

import Foundation

struct WithCheckListItemDetail {
	let title: String
	let updatedAt: String
	let createdAt: String
	let sharedChecklistID: String
	let messages: [CRDTData]
}
