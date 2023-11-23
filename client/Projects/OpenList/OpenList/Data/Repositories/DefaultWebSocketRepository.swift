//
//  DefaultWebSocketRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import CustomSocket
import Foundation

final class DefaultWebSocketRepository: NSObject {
	private let webSocket: WebSocket
	
	init(url: URL) {
		let webSocket = WebSocket()
		webSocket.url = url
		self.webSocket = webSocket
		super.init()
		setUp()
	}
	
	func setUp() {
		webSocket.delegate = self
		try? webSocket.openWebSocket()
	}
}

extension DefaultWebSocketRepository: WebSocketRepository {
	func send(data: Data) {
		webSocket.send(data: data)
	}
	
	func receive() async -> Node {
		return await withCheckedContinuation { continuation in
			webSocket.receive(onReceive: { (_, data) in
				guard
					let data,
					let response = try? JSONDecoder().decode(Node.self, from: data)
				else { return }
				continuation.resume(returning: response)
			})
		}
	}
}

extension DefaultWebSocketRepository: URLSessionWebSocketDelegate {
	func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didOpenWithProtocol protocol: String?
	) {
		print("open")
	}
	
	func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
		reason: Data?
	) {
		print("close")
	}
}
