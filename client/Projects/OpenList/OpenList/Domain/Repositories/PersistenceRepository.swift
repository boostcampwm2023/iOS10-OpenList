//
//  PersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol PersistenceRepository {
	func saveCheckList() -> Data
}
