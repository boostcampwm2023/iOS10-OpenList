//
//  DefaultAuthRepository.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import CustomNetwork
import Foundation

final class DefaultAuthRepository {
	private let session: CustomSession

	init(session: CustomSession = .init()) {
		self.session = session
	}
}

extension DefaultAuthRepository: AuthRepository {
	func postLoginInfo(loginInfo: LoginInfo) async -> LoginResponseDTO? {
		var builder = URLRequestBuilder(url: "https://openlist.kro.kr/auth/login/")
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		
		do {
			let body = try JSONEncoder().encode(loginInfo)
			builder.setBody(body)
			
			let service = NetworkService(
				customSession: session,
				urlRequestBuilder: builder
			)
			
			let data = try await service.postData()
			let loginResponseDTO = try JSONDecoder().decode(LoginResponseDTO.self, from: data)
			dump("Login Success: \(loginResponseDTO.accessToken)")
			return loginResponseDTO
		} catch {
			dump("Login Failed")
			return nil
		}
	}
}
