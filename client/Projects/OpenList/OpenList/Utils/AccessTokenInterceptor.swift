//
//  AccessTokenInterceptor.swift
//  OpenList
//
//  Created by Hoon on 11/30/23.
//

import CustomNetwork
import Foundation

final class AccessTokenInterceptor: RequestInterceptor {
	public func intercept(_ request: URLRequest) -> URLRequest {
		var request = request
		if let accessToken = KeyChain.shared.read(key: AuthKey.accessToken) {
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			return request
		} else {
			return request
		}
	}
}
