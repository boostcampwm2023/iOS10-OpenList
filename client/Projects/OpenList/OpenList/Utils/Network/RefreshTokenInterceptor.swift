//
//  RefreshTokenInterceptor.swift
//  OpenList
//
//  Created by wi_seong on 12/13/23.
//

import CustomNetwork
import Foundation

struct RefreshTokenInterceptor: RequestInterceptor {
	public func intercept(_ request: URLRequest) -> URLRequest {
		var request = request

		if let refreshToken = KeyChain.shared.read(key: AuthKey.refreshToken) {
			request.addValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
			return request
		} else {
			return request
		}
	}
}
