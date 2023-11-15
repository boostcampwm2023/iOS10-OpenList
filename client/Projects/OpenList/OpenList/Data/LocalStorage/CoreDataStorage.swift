//
//  CoreDataStorage.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol CoreDataStorage {
	func load() -> Data
	@discardableResult
	func save() -> Data
	@discardableResult
	func remove() -> Data
	@discardableResult
	func removeAll() -> Data
}

final class DefaultCoreDataStorage { }

extension DefaultCoreDataStorage: CoreDataStorage {
	func save() -> Data {
		return Data()
	}
	
	func load() -> Data {
		return Data()
	}
	
	func remove() -> Data {
		return Data()
	}
	
	func removeAll() -> Data {
		return Data()
	}
}
