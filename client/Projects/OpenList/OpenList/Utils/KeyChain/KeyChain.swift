//
//  KeyChain.swift
//  OpenList
//
//  Created by Hoon on 11/26/23.
//

import Foundation
import Security

class KeyChain {
	// Create
	static func create(key: String, token: String) {
		let query: NSDictionary = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key,
			kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
		]
		SecItemDelete(query)
		
		let status = SecItemAdd(query, nil)
		assert(status == noErr, "failed to save Token")
	}
	
	// Read
	static func read(key: String) -> String? {
		let query: NSDictionary = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key,
			kSecReturnData: kCFBooleanTrue as Any,
			kSecMatchLimit: kSecMatchLimitOne
		]
		
		var dataTypeRef: AnyObject?
		let status = SecItemCopyMatching(query, &dataTypeRef)
		
		if status == errSecSuccess {
			if let retrievedData: Data = dataTypeRef as? Data {
				let value = String(data: retrievedData, encoding: String.Encoding.utf8)
				return value
			} else { return nil }
		} else {
			print("failed to loading, status code = \(status)")
			return nil
		}
	}
	
	// Delete
	static func delete(key: String) {
		let query: NSDictionary = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: key
		]
		let status = SecItemDelete(query)
		assert(status == noErr, "failed to delete the value, status code = \(status)")
	}
}
