//
//  UserDefaultsManager.swift
//  OpenList
//
//  Created by Hoon on 12/4/23.
//

import Foundation

final class UserDefaultsManager {
	private let defaults = UserDefaults.standard

	// 데이터 저장
	static func save<T: Codable>(_ value: T, forKey key: String) {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(value) {
			UserDefaultsManager().defaults.set(encoded, forKey: key)
		}
	}
	
	// 데이터 읽기
	static func load<T: Codable>(forKey key: String, type: T.Type) -> T? {
		if let savedData = UserDefaultsManager().defaults.object(forKey: key) as? Data {
			let decoder = JSONDecoder()
			if let loadedData = try? decoder.decode(type, from: savedData) {
				return loadedData
			}
		}
		return nil
	}
	
	// 데이터 삭제
	static func remove(forKey key: String) {
		UserDefaultsManager().defaults.removeObject(forKey: key)
	}
}
