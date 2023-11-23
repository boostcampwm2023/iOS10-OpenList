//
//  WebSocketUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import Foundation

protocol WebSocketUseCase {
	func connect() -> Bool
	func send(data: Data)
	func send(message: CRDTMessage)
	func receive() async -> Node
}

final class DefaultWebSocketUseCase {
	private let webSocketRepository: WebSocketRepository
	
	init(webSocketRepository: WebSocketRepository) {
		self.webSocketRepository = webSocketRepository
	}
}

extension DefaultWebSocketUseCase: WebSocketUseCase {
	func connect() -> Bool {
		guard let data = Device.id.data(using: .utf8) else {
			return false
		}
		webSocketRepository.send(data: data)
		return true
	}
	
	func send(data: Data) {
		webSocketRepository.send(data: data)
	}
	
	func send(message: CRDTMessage) {
		let node = Node(id: Device.id, message: message)
		guard let data = try? JSONEncoder().encode(node) else {
			return
		}
		webSocketRepository.send(data: data)
	}
	
	func receive() async -> Node {
		return await webSocketRepository.receive()
	}
}
