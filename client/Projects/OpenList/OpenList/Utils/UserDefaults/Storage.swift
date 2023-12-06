//
//  Storage.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

final class Storage {
	static let shared = Storage()
	private let defaults = UserDefaults.standard
	
	private init() { }
	
	func save(key: StoargeKey, value: Any) {
		defaults.set(value, forKey: key.rawValue)
	}
	
	func fetch(key: StoargeKey) -> Any? {
		return defaults.object(forKey: key.rawValue)
	}
}

enum StoargeKey: String {
	case nickname
	case profile
}
