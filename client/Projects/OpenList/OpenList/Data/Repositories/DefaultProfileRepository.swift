//
//  DefaultProfileRepository.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import CustomNetwork
import Foundation

final class DefaultProfileRepository {
	private let session: CustomSession
	
	init(session: CustomSession) {
		self.session = session
	}
}

extension DefaultProfileRepository: ProfileRepository {
	func updateProfile(to data: Data) async throws { }
	
	func updateNickname(to nickname: String) async throws { }
}
