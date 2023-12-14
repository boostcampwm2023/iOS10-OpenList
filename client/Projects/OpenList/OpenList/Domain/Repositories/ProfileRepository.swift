//
//  ProfileRepository.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

protocol ProfileRepository {
	func updateProfile(to data: Data) async throws
	func updateNickname(to nickname: String) async throws
}
