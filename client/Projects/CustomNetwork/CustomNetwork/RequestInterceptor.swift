//
//  RequestInterceptor.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public protocol RequestInterceptor {
	func intercept(_ request: URLRequest) -> URLRequest
}

public final class AuthRequestInterceptor: RequestInterceptor {
	private let token: String
	
	public init(token: String) {
		self.token = token
	}
	
	public func intercept(_ request: URLRequest) -> URLRequest {
		var request = request
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}
