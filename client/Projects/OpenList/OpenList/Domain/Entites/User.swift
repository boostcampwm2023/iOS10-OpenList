//
//  User.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Foundation

struct User: Hashable {
	private var id: Int { userId }
	let userId: Int
	let email: String?
	let fullName: String?
	var nickname: String?
	var profileImage: String?
}
