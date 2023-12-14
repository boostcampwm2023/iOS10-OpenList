//
//  SettingRepository.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

protocol SettingRepository {
	func logOut() async throws
	func deleteAccount() async throws
}
