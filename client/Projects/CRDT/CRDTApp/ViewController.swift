//
//  ViewController.swift
//  CRDTApp
//
//  Created by 김영균 on 11/22/23.
//

import CRDT
import UIKit

final class OperationBasedViewController: UIViewController {
	private let stackView: UIStackView = .init()
	private let inputTextField: UITextField = .init()
	private let rgaSDocument: RGASDocument<String> = .init()
	private lazy var merge0: RGASMerge<String> = .init(doc: rgaSDocument, siteID: 0)
	
	private let decoder: JSONDecoder = .init()
	private let encoder: JSONEncoder = .init()
	private let deviceId = UIDevice.current.identifierForVendor!.uuidString
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setViewHieracies()
		setViewAttributes()
		setViewConstraints()
		setWebSocket()
	}
}

private extension OperationBasedViewController {
	func crdt(at response: Node) throws {
		if response.event != deviceId {
			try response.data.execute(on: merge0)
			DispatchQueue.main.async { [weak self] in
				self?.inputTextField.text = self?.rgaSDocument.view()
			}
			printDocument(document: rgaSDocument)
		}
	}
	
	func insertOperation(range: NSRange, content: [String]) throws {
		let sequenceOperation = SequenceOperation<String>(
			type: .insert,
			position: range.location,
			argument: 0,
			content: content
		)
		let message = try merge0.applyLocal(to: sequenceOperation)
		try sendMessage(to: message)
	}
	
	func deleteOperation(range: NSRange, content: [String]) throws {
		let sequenceOperation = SequenceOperation<String>(
			type: .delete,
			position: range.location,
			argument: 1,
			content: content
		)
		let message = try merge0.applyLocal(to: sequenceOperation)
		try sendMessage(to: message)
	}
	
	func sendMessage(to message: CRDTMessage) throws {
		let node = Node(event: deviceId, data: message)
		let data = try encoder.encode(node)
		printDocument(document: rgaSDocument)
		WebSocket.shared.send(data: data)
	}
	
	func apply<T>(
		rgaDocument: RGASDocument<T>,
		sequenceOperation: SequenceOperation<String>,
		merge: RGASMerge<T>,
		shouldPrint: Bool
	) throws {
		let message = try merge0.applyLocal(to: sequenceOperation)
		debugPrint(message)
		if shouldPrint {
			printDocument(document: rgaDocument)
		}
	}
	
	func printDocument<T>(document: RGASDocument<T>) {
		print("ListedChain with sep: \(document.viewWithSeparator())")
		print("Size of doc: \(document.viewLength())")
		print("ListedChain view: \(document.view())")
		print(document.treeViewWithSeparator(tree: document.root, depth: 0))
		print("\n\n")
	}
}

private extension OperationBasedViewController {
	func setViewAttributes() {
		view.backgroundColor = .systemBackground
		setInputTextFieldAttributes()
		setStackViewAttributes()
	}
	
	func setInputTextFieldAttributes() {
		inputTextField.translatesAutoresizingMaskIntoConstraints = false
		inputTextField.borderStyle = .line
		inputTextField.delegate = self
	}
	
	func setStackViewAttributes() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 20
		stackView.axis = .vertical
	}
	
	func setViewHieracies() {
		stackView.addArrangedSubview(inputTextField)
		view.addSubview(stackView)
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			stackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
			stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
		])
	}
	
	func setWebSocket() {
		WebSocket.shared.url = URL(string: "ws://localhost:1337/")
		WebSocket.shared.delegate = self
		try? WebSocket.shared.openWebSocket()
		WebSocket.shared.send(message: deviceId)
		WebSocket.shared.receive(onReceive: { [weak self] (_, data) in
			guard
				let data,
				let response = try? self?.decoder.decode(Node.self, from: data)
			else { return }
			
			try? self?.crdt(at: response)
		})
	}
}

extension OperationBasedViewController: UITextFieldDelegate {
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		let content = string.map { String($0) }
		
		do {
			switch range.length {
			case 0:
				try insertOperation(range: range, content: content)
			case 1:
				try deleteOperation(range: range, content: content)
			default:
				try deleteOperation(range: range, content: content)
			}
		} catch {
			print(error)
		}
		return true
	}
}

extension OperationBasedViewController: URLSessionWebSocketDelegate {
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
