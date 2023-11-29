//
//  Category.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

struct Category: Encodable {
	var title: String?
	var mainCategory: String?
	var subCategory: String?
	var minorCategory: String?
	
	init(
		title: String? = nil,
		mainCategory: String? = nil,
		subCategory: String? = nil,
		minorCategory: String? = nil
	) {
		self.title = title
		self.mainCategory = mainCategory
		self.subCategory = subCategory
		self.minorCategory = minorCategory
	}
}
