//
//  Document.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

public protocol Document {
	// View of the document (without metadata)
	func view() -> String
	
	// Length of the view (to generate random operations)
	func viewLength() -> Int
	
	// Applies a character operation
	func apply(operation: any Operation) throws
}
