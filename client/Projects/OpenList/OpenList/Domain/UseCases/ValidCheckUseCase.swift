//
//  ValidCheckUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol ValidCheckUseCase {
	func validateTextLength(_ text: String, in length: Int) -> Bool
}

final class DefaultValidCheckUseCase { }

extension DefaultValidCheckUseCase: ValidCheckUseCase {
	func validateTextLength(_ text: String, in length: Int) -> Bool {
		if text.isEmpty { return false }
		return text.count <= length
	}
}
