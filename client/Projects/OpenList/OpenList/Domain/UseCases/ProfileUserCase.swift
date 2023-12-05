//
//  ProfileUserCase.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

protocol ProfileUserCase {
	func updateProfile()
	func updateNickname(to nickname: String)
}

final class DefaultProfileUserCase {
	private let profileRepository: ProfileRepository
	
	init(profileRepository: ProfileRepository) {
		self.profileRepository = profileRepository
	}
}

extension DefaultProfileUserCase: ProfileUserCase {
	func updateProfile() { }
	
	func updateNickname(to nickname: String) {
		Storage.shared.save(key: .nickname, value: nickname)
	}
}
