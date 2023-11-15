//
//  CustomSession.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public final class CustomSession {
	private let session: URLSession
	private let interceptor: RequestInterceptor?
	private let retrier: RequestRetrier?
	
	public init(
		configuration: URLSessionConfiguration = .default,
		interceptor: RequestInterceptor? = nil,
		retrier: RequestRetrier? = nil
	) {
		self.session = URLSession(configuration: configuration)
		self.interceptor = interceptor
		self.retrier = retrier
	}
	
	func data(
		for request: URLRequest,
		attempt: Int = 0
	) async throws -> (Data, URLResponse) {
		var currentRequest = interceptor?.intercept(request) ?? request
		var currentAttempt = attempt
		
		repeat {
			do {
				let (data, response) = try await session.data(for: currentRequest)
				return (data, response)
			} catch {
				if let retrier = retrier,
					retrier.shouldRetry(currentRequest, with: error, attempt: currentAttempt) {
					if let retriedRequest = retrier.retry(currentRequest, with: error, attempt: currentAttempt) {
						currentRequest = retriedRequest
						currentAttempt += 1
						continue
					}
				}
				throw error
			}
		} while true
	}
}
