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
	
	public func getData() async throws -> Data {
		var builder = urlRequestBuilder
		_ = builder.setMethod(.get)
		guard let request = builder.build() else {
			throw NetworkError.invalidRequest
		}
		return try await sendRequest(request)
	}
	
	public func postData() async throws -> Data {
		var builder = urlRequestBuilder
		_ = builder.setMethod(.post)
		guard let request = builder.build() else {
			throw NetworkError.invalidRequest
		}
		return try await sendRequest(request)
	}
	
	public func putData() async throws -> Data {
		var builder = urlRequestBuilder
		_ = builder.setMethod(.put)
		guard let request = builder.build() else {
			throw NetworkError.invalidRequest
		}
		return try await sendRequest(request)
	}
	
	public func deleteData() async throws -> Data {
		var builder = urlRequestBuilder
		_ = builder.setMethod(.delete)
		guard let request = builder.build() else {
			throw NetworkError.invalidRequest
		}
		return try await sendRequest(request)
	}
	
	public func patchData() async throws -> Data {
		var builder = urlRequestBuilder
		_ = builder.setMethod(.patch)
		guard let request = builder.build() else {
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
