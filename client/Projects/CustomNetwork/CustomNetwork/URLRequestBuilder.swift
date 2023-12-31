//
//  URLRequestBuilder.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public struct URLRequestBuilder {
	private var url: URL?
	private var method: HTTPMethod = .get
	private var headers: [String: String] = [:]
	private var body: Data?
	
	public enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
		case patch = "PATCH"
	}
	
	public init(url: String) {
		self.url = URL(string: url)
	}
	
	@discardableResult
	mutating public func setMethod(_ method: HTTPMethod) -> URLRequestBuilder {
		self.method = method
		return self
	}
	
	@discardableResult
	mutating public func addHeader(field: String, value: String) -> URLRequestBuilder {
		headers[field] = value
		return self
	}
	
	@discardableResult
	mutating public func setBody(_ body: Data) -> URLRequestBuilder {
		self.body = body
		return self
	}
	
	@discardableResult
	mutating public func addPath(_ path: String) -> URLRequestBuilder {
		url?.append(path: path)
		return self
	}
	
	@discardableResult
	mutating public func addQuery(parameter: [String: String]) -> URLRequestBuilder {
		guard let url = self.url else { return self }
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		components?.percentEncodedQuery = parameter
			.map { $0.key + "=" + $0.value }
			.joined(separator: "&")
			.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		self.url = components?.url
		return self
	}
	
	func build() -> URLRequest? {
		guard let url = url else { return nil }
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.allHTTPHeaderFields = headers
		request.httpBody = body
		return request
	}
}
