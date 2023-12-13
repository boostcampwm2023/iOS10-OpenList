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

public final class SimpleRequestRetrier: RequestRetrier {
	private let maxAttempts: Int
	
	public init(maxAttempts: Int = 3) {
		self.maxAttempts = maxAttempts
	}
	
	public func shouldRetry(_ request: URLRequest, with error: Error, attempt: Int) -> Bool {
		return attempt < maxAttempts
	}
	
	public func retry(_ request: URLRequest, with error: Error, attempt: Int) async -> URLRequest? {
		return request
	}
}
