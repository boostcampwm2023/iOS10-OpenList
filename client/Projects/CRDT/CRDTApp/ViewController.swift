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
		if response.id != deviceId {
			try response.message.execute(on: merge0)
			DispatchQueue.main.async { [weak self] in
				self?.inputTextField.text = self?.rgaSDocument.view()
			}
			printDocument(document: rgaSDocument)
		}
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
		let stringArray = string.map { String($0) }
		switch range.length {
		case 0:
			let sequenceOperation = SequenceOperation<String>(
				type: .insert,
				position: range.location,
				argument: 0,
				content: stringArray
			)
			let message = try? merge0.applyLocal(to: sequenceOperation)
			let node = Node(id: deviceId, message: message!)
			guard let data = try? encoder.encode(node) else {
				break
			}
			printDocument(document: rgaSDocument)
			WebSocket.shared.send(data: data)
		case 1:
			let sequenceOperation = SequenceOperation<String>(
				type: .delete,
				position: range.location,
				argument: 1,
				content: stringArray
			)
			let message = try? merge0.applyLocal(to: sequenceOperation)
			let node = Node(id: deviceId, message: message!)
			guard let data = try? encoder.encode(node) else {
				break
			}
			printDocument(document: rgaSDocument)
			WebSocket.shared.send(data: data)
		default:
			let sequenceOperation = SequenceOperation<String>(
				type: .delete,
				position: range.location,
				argument: range.length,
				content: stringArray
			)
			let message = try? merge0.applyLocal(to: sequenceOperation)
			let node = Node(id: deviceId, message: message!)
			guard let data = try? encoder.encode(node) else {
				break
			}
			WebSocket.shared.send(data: data)
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
