//
//  NetworkServiceTests.swift
//  CustomNetworkTests
//
//  Created by wi_seong on 11/15/23.
//

@testable import CustomNetwork
import XCTest

final class NetworkServiceTests: XCTestCase {
	func createService(_ method: URLRequestBuilder.HTTPMethod) -> NetworkService {
		let configuration: URLSessionConfiguration = .ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		let customSession = CustomSession(configuration: configuration)
		var urlRequestBuilder = URLRequestBuilder(url: "https://google.com/")
		urlRequestBuilder.setMethod(method)
		let service = NetworkService(customSession: customSession, urlRequestBuilder: urlRequestBuilder)
		return service
	}
	
	func testGetData() async {
		let service = createService(.get)
		let response = """
			{
				"result": "OK",
				"status": "200"
			}
		"""
		
		let data = response.data(using: .utf8)!
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			guard let url = request.url,
				let response = HTTPURLResponse(
					url: url,
					statusCode: 200,
					httpVersion: nil,
					headerFields: ["Content-Type": "application/json"]
				)
			else {
				return (HTTPURLResponse(), data)
			}
			return (response, data)
		}
		
		do {
			let result = try await service.request()
			XCTAssertEqual(result, data, "Get data should match expected data")
		} catch {
			XCTFail("Expected successful get, but got error: \(error)")
		}
	}
	
	func testPostData() async {
		let service = createService(.post)
		let response = """
			{
				"result": "OK",
				"status": "200"
			}
		"""
		
		let data = response.data(using: .utf8)!
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			guard let url = request.url,
				let response = HTTPURLResponse(
					url: url,
					statusCode: 200,
					httpVersion: nil,
					headerFields: ["Content-Type": "application/json"]
				)
			else {
				return (HTTPURLResponse(), data)
			}
			return (response, data)
		}
		
		do {
			let result = try await service.request()
			XCTAssertEqual(result, data, "Post data should match expected data")
		} catch {
			XCTFail("Expected successful post, but got error: \(error)")
		}
	}
	
	func testPutData() async {
		let service = createService(.put)
		let response = """
			{
				"result": "OK",
				"status": "200"
			}
		"""
		
		let data = response.data(using: .utf8)!
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			guard let url = request.url,
				let response = HTTPURLResponse(
					url: url,
					statusCode: 200,
					httpVersion: nil,
					headerFields: ["Content-Type": "application/json"]
				)
			else {
				return (HTTPURLResponse(), data)
			}
			return (response, data)
		}
		
		do {
			let result = try await service.request()
			XCTAssertEqual(result, data, "Put data should match expected data")
		} catch {
			XCTFail("Expected successful put, but got error: \(error)")
		}
	}
	
	func testDeleteData() async {
		let service = createService(.delete)
		let response = """
			{
				"result": "OK",
				"status": "200"
			}
		"""
		
		let data = response.data(using: .utf8)!
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			guard let url = request.url,
				let response = HTTPURLResponse(
					url: url,
					statusCode: 200,
					httpVersion: nil,
					headerFields: ["Content-Type": "application/json"]
				)
			else {
				return (HTTPURLResponse(), data)
			}
			return (response, data)
		}
		
		do {
			let result = try await service.request()
			XCTAssertEqual(result, data, "Delete data should match expected data")
		} catch {
			XCTFail("Expected successful delete, but got error: \(error)")
		}
	}
	
	func testPatchData() async {
		let service = createService(.patch)
		let response = """
			{
				"result": "OK",
				"status": "200"
			}
		"""
		
		let data = response.data(using: .utf8)!
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			guard let url = request.url,
				let response = HTTPURLResponse(
					url: url,
					statusCode: 200,
					httpVersion: nil,
					headerFields: ["Content-Type": "application/json"]
				)
			else {
				return (HTTPURLResponse(), data)
			}
			return (response, data)
		}
		
		do {
			let result = try await service.request()
			XCTAssertEqual(result, data, "Patch data should match expected data")
		} catch {
			XCTFail("Expected successful patch, but got error: \(error)")
		}
	}
}
