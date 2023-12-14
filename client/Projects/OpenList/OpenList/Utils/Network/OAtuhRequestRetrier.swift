//
//  OAtuhRequestRetrier.swift
//  OpenList
//
//  Created by wi_seong on 12/13/23.
//

import CustomNetwork
import Foundation

struct OAtuhRequestRetrier: RequestRetrier {
	private let maxAttempts: Int
	private let session = CustomSession(interceptor: RefreshTokenInterceptor())

	init(maxAttempts: Int = 3) {
		self.maxAttempts = maxAttempts
	}

	func shouldRetry(_ request: URLRequest, with error: Error, attempt: Int) -> Bool {
		return attempt < maxAttempts
	}

	func retry(_ request: URLRequest, with error: Error, attempt: Int) async -> URLRequest? {
		do {
			try await refresh()
			var request = request
			guard let token = KeyChain.shared.read(key: AuthKey.accessToken) else { return nil }
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			return request
		} catch {
			return nil
		}
	}
}

private extension OAtuhRequestRetrier {
	func refresh() async throws {
		var builder = URLRequestBuilder(url: "https://openlist.kro.kr/auth/token/access")
		builder.addHeader(field: "Content-Type", value: "application/json")
		builder.setMethod(.post)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let tokens = try JSONDecoder().decode(TokenResponseDTO.self, from: data)
		saveToken(tokens)
	}

	func saveToken(_ tokens: TokenResponseDTO) {
		KeyChain.shared.create(key: AuthKey.accessToken, token: tokens.accessToken)
		KeyChain.shared.create(key: AuthKey.refreshToken, token: tokens.refreshToken)
	}
}
