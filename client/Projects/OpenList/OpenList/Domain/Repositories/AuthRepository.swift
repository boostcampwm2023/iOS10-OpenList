//
//  AuthRepository.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol AuthRepository {
	func postLoginInfo(identityToken: String, provider: String) async -> Bool
}
