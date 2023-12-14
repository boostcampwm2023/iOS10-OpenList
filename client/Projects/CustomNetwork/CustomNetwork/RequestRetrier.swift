//
//  RequestRetrier.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public protocol RequestRetrier {
	func shouldRetry(_ request: URLRequest, with error: Error, attempt: Int) -> Bool
	func retry(_ request: URLRequest, with error: Error, attempt: Int) async -> URLRequest?
}
