//
//  LocalOperation.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

protocol LocalOperation<T>: Operation {
	mutating func adaptTo(replica: CRDT<T>) throws -> any LocalOperation
}
