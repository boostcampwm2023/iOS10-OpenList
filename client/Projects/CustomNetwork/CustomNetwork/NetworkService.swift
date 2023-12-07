//
//  NetworkService.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public final class NetworkService {
	private let customSession: CustomSession
	private let urlRequestBuilder: URLRequestBuilder
	
	public init(customSession: CustomSession, urlRequestBuilder: URLRequestBuilder) {
		self.customSession = customSession
		self.urlRequestBuilder = urlRequestBuilder
	}
	
	@discardableResult
	public func request() async throws -> Data {
		guard let request = urlRequestBuilder.build() else {
			throw NetworkError.invalidRequest
		}
		return try await sendRequest(request)
	}
	
	private func sendRequest(_ request: URLRequest) async throws -> Data {
		let (data, response) = try await customSession.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkError.invalidResponse
		}
		guard (200...299).contains(httpResponse.statusCode) else {
			throw NetworkError.serverError(statusCode: httpResponse.statusCode)
		}
		return data
	}
}
