//
//  ViewBindable.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Foundation

protocol ViewBindable {
	associatedtype State
	associatedtype OutputError: Error
	
	func bind()
	func render(_ state: State)
	func handleError(_ error: OutputError)
}

extension ViewBindable {
	func handleError(_ error: OutputError) { }
}
