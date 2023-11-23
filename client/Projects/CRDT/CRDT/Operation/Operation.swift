//
//  Operation.swift
//  crdt
//
//  Created by wi_seong on 11/17/23.
//

import Foundation

public protocol Operation: Codable {
	associatedtype T
	func clone() -> Self
}
