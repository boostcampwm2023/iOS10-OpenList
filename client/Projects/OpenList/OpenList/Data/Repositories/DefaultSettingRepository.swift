//
//  DefaultSettingRepository.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import CustomNetwork
import Foundation

final class DefaultSettingRepository {
	private let checkListStorage: PrivateCheckListStorage
	private let session: CustomSession
	
	init(
		checkListStorage: PrivateCheckListStorage,
		session: CustomSession
	) {
		self.checkListStorage = checkListStorage
		self.session = session
	}
}

extension DefaultSettingRepository: SettingRepository {
	func logOut() async throws {
		deleteToken()
		// API Call
	}
	
	func deleteAccount() async throws {
		deleteToken()
		try checkListStorage.removeAllCheckList()
		// API Call
	}
}

private extension DefaultSettingRepository {
	func deleteToken() {
		KeyChain.shared.delete(key: AuthKey.accessToken)
		KeyChain.shared.delete(key: AuthKey.refreshToken)
	}
}
