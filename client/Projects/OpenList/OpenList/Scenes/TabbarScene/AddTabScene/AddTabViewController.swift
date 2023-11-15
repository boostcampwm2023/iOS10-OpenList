//
//  AddTabViewController.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine
import UIKit

protocol AddTabRoutingLogic: AnyObject { }

final class AddTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: AddTabRoutingLogic
  private let viewModel: any AddTabViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
  private var cancellables: Set<AnyCancellable> = []

	// MARK: - UI Components
	private var nextButton: ConfirmButton = .init(title: "다음")
	private var titleTextField: UITextField = .init()
	private var titleLabel: UILabel = .init()

  // MARK: - Initializers
	init(
		router: AddTabRoutingLogic,
		viewModel: some AddTabViewModelable
	) {
		self.router = router
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

  @available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setViewAttributes()
		setViewHierachies()
		setViewConstraints()
		bind()
		viewLoad.send()
	}
}

// MARK: - Bind Methods
extension AddTabViewController: ViewBindable {
	typealias State = AddTabState
	typealias OutputError = Error

	func bind() {
		let input = AddTabInput(
			textFieldDidChange: titleTextField.valuePublisher,
			nextButtonDidTap: nextButton.tapPublisher
		)

		let output = viewModel.transform(input)

		output
			.receive(on: DispatchQueue.main)
			.sink { [weak self] in self?.render($0) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .error(let error):
			print(error)
		case .valid(let state):
			setButtonIsEnabled(state)
		case .dismiss:
			dismiss(animated: true)
		}
	}

	func handleError(_ error: OutputError) {
		print(error.localizedDescription)
	}
}

// MARK: - Helper
private extension AddTabViewController {
	func setButtonIsEnabled(_ state: Bool) {
		nextButton.isEnabled = state
	}
}

// MARK: - SetUp
private extension AddTabViewController {
	func setViewAttributes() {
		titleTextField.borderStyle = .roundedRect
		
		nextButton.isEnabled = false
	}
	
	func setViewHierachies() {
		[
			nextButton,
			titleTextField
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			titleTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			titleTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
			titleTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
			
			nextButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
			nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			nextButton.heightAnchor.constraint(equalToConstant: 56)
		])
	}
}
