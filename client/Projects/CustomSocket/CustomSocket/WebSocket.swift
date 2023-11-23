//
//  CustomSocket.swift
//  CustomSocket
//
//  Created by 김영균 on 11/11/23.
//

import Foundation

public final class WebSocket: NSObject {
	public var url: URL?
	public var onReceiveClosure: ((String?, Data?) -> Void)?
	public weak var delegate: URLSessionWebSocketDelegate?

	private var webSocketTask: URLSessionWebSocketTask? {
		didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
	}
	private var timer: Timer?

	public override init() {}

	public func openWebSocket() throws {
		guard let url = url else { throw WebSocketError.invalidURL }

		let urlSession = URLSession(
			configuration: .default,
			delegate: self,
			delegateQueue: OperationQueue()
		)
		let webSocketTask = urlSession.webSocketTask(with: url)
		webSocketTask.resume()

		self.webSocketTask = webSocketTask

		self.startPing()
	}

	public func send(message: String) {
		self.send(message: message, data: nil)
	}

	public func send(data: Data) {
		self.send(message: nil, data: data)
	}

	private func send(message: String?, data: Data?) {
		let taskMessage: URLSessionWebSocketTask.Message
		if let string = message {
			taskMessage = URLSessionWebSocketTask.Message.string(string)
		} else if let data = data {
			taskMessage = URLSessionWebSocketTask.Message.data(data)
		} else {
			return
		}

		print("Send message \(taskMessage)")
		self.webSocketTask?.send(taskMessage, completionHandler: { error in
			guard let error = error else { return }
			print("WebSOcket sending error: \(error)")
		})
	}

	public func closeWebSocket() {
		self.webSocketTask = nil
		self.timer?.invalidate()
		self.onReceiveClosure = nil
		self.delegate = nil
	}

	public func receive(onReceive: @escaping (String?, Data?) -> Void) {
		self.onReceiveClosure = onReceive
		self.webSocketTask?.receive(completionHandler: { [weak self] result in
			switch result {
			case let .success(message):
				switch message {
				case let .string(string):
					onReceive(string, nil)
				case let .data(data):
					onReceive(nil, data)
				@unknown default:
					onReceive(nil, nil)
				}
			case let .failure(error):
				print("Received error \(error)")
			}
			self?.receive(onReceive: onReceive)
		})
	}

	private func startPing() {
		self.timer?.invalidate()
		self.timer = Timer.scheduledTimer(
			withTimeInterval: 10,
			repeats: true,
			block: { [weak self] _ in self?.ping() }
		)
	}
	private func ping() {
		self.webSocketTask?.sendPing(pongReceiveHandler: { [weak self] error in
			guard let error = error else { return }
			print("Ping failed \(error)")
			self?.startPing()
		})
	}
}

extension WebSocket: URLSessionWebSocketDelegate {
	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didOpenWithProtocol protocol: String?
	) {
		self.delegate?.urlSession?(
			session,
			webSocketTask: webSocketTask,
			didOpenWithProtocol: `protocol`
		)
	}

	public func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
		reason: Data?
	) {
		self.delegate?.urlSession?(
			session,
			webSocketTask: webSocketTask,
			didCloseWith: closeCode,
			reason: reason
		)
	}
}
