//
//  RGASOperation.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

protocol RGASOperation: Operation, Codable {
	var replica: Int { get }
	var type: OpType { get }
}
