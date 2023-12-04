//
//  AccessTokenInterceptor.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import CustomNetwork
import Foundation

final class AccessTokenInterceptor: RequestInterceptor {
	public func intercept(_ request: URLRequest) -> URLRequest {
		var request = request
		let token1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRqZGduc1Rlc3RAbm"
		let token2 = "F2ZXIuY29tIiwidXNlcklkIjoyMiwidG9rZW5UeXBlIjoiYWNjZ"
		let token3 = "XNzIiwiaWF0IjoxNzAxNjg3ODMwLCJleHAiOjE3MDIyOTI2MzB9.lBjVPBxOHNg60PdGp4W7LKPxZ6UUeM8qBjJnDLVZSKk"
		let token = (Device.id == "3225EC07-B8F0-4BD7-B7F4-C2E6DB2AFA24" ? KeyChain.shared.read(key: AuthKey.accessToken) : token1 + token2 + token3)
		print(token)
		if let accessToken = token {
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			return request
		} else {
			return request
		}
	}
}
