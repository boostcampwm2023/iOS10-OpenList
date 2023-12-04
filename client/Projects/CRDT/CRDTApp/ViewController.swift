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
	private var oldString: String = ""
	private var replacementString: [String] = []
	private var range: NSRange = .init()
	
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
	
	func replaceOperation(range: NSRange, content: [String], argument: Int = 1) throws {
		let sequenceOperation = SequenceOperation<String>(
			type: .replace,
			position: range.location,
			argument: argument,
			content: content
		)
		let message = try merge0.applyLocal(to: sequenceOperation)
		try sendMessage(to: message)
	}
	
	func sendMessage(to message: CRDTMessage) throws {
		let node = Node(event: deviceId, data: message)
		let data = try encoder.encode(node)
		if
			let text = inputTextField.text,
			rgaSDocument.view() != text
		{
			DispatchQueue.main.async { [weak self] in
				self?.inputTextField.text = self?.rgaSDocument.view()
			}
			printDocument(document: rgaSDocument)
		}
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
		inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
		guard let oldString = textField.text else { return false }
		let content = string.map { String($0) }
		self.range = range
		self.oldString = oldString
		self.replacementString = content
		
		return range.length < 2
	}
	
	@objc func textFieldDidChange(_ sender: Any?) {
		guard let currentText = inputTextField.text else { return }
		
		do {
			let lengthChange = Comparison(currentText.count, oldString.count)
			switch lengthChange {
			case .less:
				try lengthChangeLess(currentText)
			case .equal:
				try lengthChangeEqual(currentText)
			case .more:
				try lengthChangeMore(currentText)
			}
		} catch {
			print(error)
		}
	}
}

private extension OperationBasedViewController {
	func lengthChangeLess(_ currentText: String) throws {
		if range.location == 0 {
			try deleteOperation(range: range, content: replacementString)
		} else {
			let location = range.location - 1
			let currentString = currentText.subString(offsetBy: location)
			let prevString = oldString.subString(offsetBy: location)
			
			if currentString == prevString {
				try deleteOperation(range: range, content: replacementString)
			} else {
				let content = currentString.map { String($0) }
				try replaceOperation(
					range: .init(location: location, length: range.length),
					content: content,
					argument: 2
				)
			}
		}
	}
	
	func lengthChangeEqual(_ currentText: String) throws {
		let location: Int = (range.length == 0) ? range.location - 1 : range.location
		let string = currentText.subString(offsetBy: location)
		let content = string.map { String($0) }
		try replaceOperation(range: .init(location: location, length: range.length), content: content)
	}
	
	func lengthChangeMore(_ currentText: String) throws {
		var string = currentText.subString(offsetBy: range.location)
		guard let value2 = UnicodeScalar(String(string))?.value else { return }
		
		if value2 < 0xac00 {
			let content = string.map { String($0) }
			try insertOperation(range: range, content: content)
		} else {
			let location = range.location - 1
			let prevString = currentText.subString(offsetBy: location)
			string = prevString + string
			let content = string.map { String($0) }
			try replaceOperation(range: .init(location: location, length: range.length + 1), content: content)
		}
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
