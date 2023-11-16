//
//  NetworkError.swift
//  CustomNetwork
//
//  Created by wi_seong on 11/14/23.
//

import Foundation

public enum NetworkError: Error {
	case invalidURL
	case invalidResponse
	case invalidRequest
	case noData
	case decodingFailed
	case unknown
	case custom(String)
	case serverError(statusCode: Int)
	
	var localizedDescription: String {
		switch self {
		case .invalidURL:
			return "Invalid URL"
		case .invalidResponse:
			return "Invalid Response"
		case .invalidRequest:
			return "Invalid Request"
		case .noData:
			return "No data received"
		case .decodingFailed:
			return "Failed to decode the data"
		case .unknown:
			return "An unknown error occurred"
		case .custom(let message):
			return message
		case .serverError(let statusCode):
			return "\(statusCode)"
		}
	}
}
