//
//  SettingUseCase.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

protocol SettingUseCase {
	func logOut() async throws
	func deleteAccount() async throws
}

final class DefaultSettingUseCase {
	private let settingRepository: SettingRepository
	
	init(settingRepository: SettingRepository) {
		self.settingRepository = settingRepository
	}
}

extension DefaultSettingUseCase: SettingUseCase {
	func logOut() async throws {
		try await settingRepository.logOut()
	}
	
	func deleteAccount() async throws {
		try await settingRepository.deleteAccount()
	}
}
