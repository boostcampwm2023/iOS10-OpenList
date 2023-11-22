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
			printDocument(doc: rgaSDocument)
		}
	}
	
	func apply<T>(rgadoc: RGASDocument<T>, so: SequenceOperation<String>, merge: RGASMerge<T>, shouldPrint: Bool) throws {
		let message = try merge0.applyLocal(op: so)
		debugPrint(message)
		if shouldPrint {
			printDocument(doc: rgadoc)
		}
	}
	
	func printDocument<T>(doc: RGASDocument<T>) {
		print("ListedChain with sep: \(doc.viewWithSeparator())")
		print("Size of doc: \(doc.viewLength())")
		print("ListedChain view: \(doc.view())")
		print(doc.treeViewWithSeparator(tree: doc.root, depth: 0))
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
		WebSocket.shared.receive(onReceive: { [weak self] (jsonString, data) in
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
			let so = SequenceOperation<String>(type: .insert, position: range.location, argument: 0, content: stringArray)
			let message = try? merge0.applyLocal(op: so)
			let node = Node(id: deviceId, message: message!)
			guard let data = try? encoder.encode(node) else {
				break
			}
			printDocument(doc: rgaSDocument)
			WebSocket.shared.send(data: data)
		case 1:
			let so = SequenceOperation<String>(type: .delete, position: range.location, argument: 1, content: stringArray)
			let message = try? merge0.applyLocal(op: so)
			let node = Node(id: deviceId, message: message!)
			guard let data = try? encoder.encode(node) else {
				break
			}
			printDocument(doc: rgaSDocument)
			WebSocket.shared.send(data: data)
		default:
			let so = SequenceOperation<String>(type: .delete, position: range.location, argument: range.length, content: stringArray)
			let message = try? merge0.applyLocal(op: so)
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
