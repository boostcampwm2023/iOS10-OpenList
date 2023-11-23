//
//  OpType.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public enum OpType: Codable {
	case insert
	case delete
	case replace
	case update
	case move
	case unsupported
	case noop
	case revert
	case undo
}
