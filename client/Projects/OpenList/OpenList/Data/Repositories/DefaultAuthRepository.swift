//
//  DefaultAuthRepository.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import CustomNetwork
import Foundation

final class DefaultAuthRepository {
	private var service: NetworkService
	private var urlRequestBuilder: URLRequestBuilder
	private let session: CustomSession
	
	init() {
		let configuration: URLSessionConfiguration = .default
		configuration.protocolClasses = [URLProtocol.self]
		self.session = CustomSession(configuration: configuration)
		self.urlRequestBuilder = URLRequestBuilder(url: "https://openlist.kro.kr/auth/login/")
		let service = NetworkService(
			customSession: session,
			urlRequestBuilder: urlRequestBuilder
		)
		self.service = service
	}
}

extension DefaultAuthRepository: AuthRepository {
	func postLoginInfo(identityToken: String, provider: String) async -> LoginResponseDTO? {
		let loginInfoDTO = LoginRequestDTO(
			identityToken: identityToken,
			provider: provider
		)
		
		do {
			let body = try JSONEncoder().encode(loginInfoDTO)
			var loginUrlRequestBuilder = urlRequestBuilder.setBody(body)
			loginUrlRequestBuilder = loginUrlRequestBuilder.addHeader(field: "Content-Type", value: "application/json")
			service = NetworkService(
				customSession: session,
				urlRequestBuilder: loginUrlRequestBuilder
			)
			let data = try await service.postData()
			let loginResponseDTO = try JSONDecoder().decode(LoginResponseDTO.self, from: data)
			print("Login Success: \(loginResponseDTO.accessToken)")
			return loginResponseDTO
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}
