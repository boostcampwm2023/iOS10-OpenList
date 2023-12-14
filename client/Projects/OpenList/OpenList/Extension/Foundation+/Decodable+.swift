//
//  Decodable+.swift
//  OpenList
//
//  Created by wi_seong on 12/3/23.
//

import Foundation

extension Decodable {
	static func map(jsonString: String) -> Self? {
		do {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			return try decoder.decode(Self.self, from: Data(jsonString.utf8))
		} catch let error {
			print(error)
			return nil
		}
	}
}
