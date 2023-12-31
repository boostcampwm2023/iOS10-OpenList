//
//  AddCheckListTitleViewController.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine
import UIKit

protocol AddCheckListTitleRoutingLogic: AnyObject {
	func routeToMainCategoryScene(with title: String)
}

final class AddCheckListTitleViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: AddCheckListTitleRoutingLogic
  private let viewModel: any AddCheckListTitleViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
  private var cancellables: Set<AnyCancellable> = []

	// MARK: - UI Components
	private var nextButton: ConfirmButton = .init(title: Typo.nextButtonTitle)
	private var titleTextField: OpenListTextField = .init()
	private var titleLabel: UILabel = .init()
	private var titleTextFieldCenterYConstraint: NSLayoutConstraint = .init()
	private var nextButtonBottomConstraints: NSLayoutConstraint = .init()

  // MARK: - Initializers
	init(
		router: AddCheckListTitleRoutingLogic,
		viewModel: some AddCheckListTitleViewModelable
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
		setViewAttributes()
		setViewHierachies()
		setViewConstraints()
		setupKeyBoardEvent()
		setupKeyboardTapAction()
		bind()
	}
}

// MARK: - Bind Methods
extension AddCheckListTitleViewController: ViewBindable {
	typealias State = AddCheckListTitleState
	typealias OutputError = Error

	func bind() {
		let input = AddCheckListTitleInput(
			textFieldDidChange: titleTextField.valuePublisher,
			nextButtonDidTap: nextButton.tapPublisher
		)
		let output = viewModel.transform(input)

		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .error(let error):
			handleError(error)
		case .valid(let state):
			setButtonIsEnabled(state)
		case .dismiss:
			debugPrint("Dismiss")
		}
	}

	func handleError(_ error: OutputError) {
		print(error.localizedDescription)
	}
}

// MARK: - Helper
private extension AddCheckListTitleViewController {
	func setButtonIsEnabled(_ state: Bool) {
		nextButton.isEnabled = state
	}
	
	@objc func nextButtonTapped() {
		guard let title = titleTextField.text else { return }
		router.routeToMainCategoryScene(with: title)
	}
}

// MARK: - SetUp
private extension AddCheckListTitleViewController {
	enum Constraint {
		static let defaultSpace = 20.0
		static let buttonHeight = 56.0
	}
	
	enum Typo {
		static let titleLabelText = "제목"
		static let titleTextFieldPlaceHolder = "체크리스트 제목"
		static let nextButtonTitle = "다음"
	}
	
	func setViewAttributes() {
		view.backgroundColor = .background
		setTitleLabel()
		setTextField()
		setNextButton()
	}
	
	func setTitleLabel() {
		titleLabel.text = Typo.titleLabelText
		titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
	}
	
	func setTextField() {
		titleTextField.autocorrectionType = .no
		titleTextField.autocapitalizationType = .none
		titleTextField.clearButtonMode = .whileEditing
		titleTextField.placeholder = Typo.titleTextFieldPlaceHolder
		titleTextField.delegate = self
	}
	
	func setNextButton() {
		nextButton.isEnabled = false
		nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
	}
	
	func setViewHierachies() {
		[
			nextButton,
			titleTextField,
			titleLabel
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		titleTextFieldCenterYConstraint = titleTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		nextButtonBottomConstraints = nextButton.bottomAnchor.constraint(
			equalTo: safeArea.bottomAnchor
		)
		NSLayoutConstraint.activate([
			titleTextFieldCenterYConstraint,
			titleTextField.leadingAnchor.constraint(
				equalTo: safeArea.leadingAnchor,
				constant: Constraint.defaultSpace
			),
			titleTextField.trailingAnchor.constraint(
				equalTo: safeArea.trailingAnchor,
				constant: -Constraint.defaultSpace
			),
			
			titleLabel.bottomAnchor.constraint(
				equalTo: titleTextField.topAnchor,
				constant: -Constraint.defaultSpace
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: safeArea.leadingAnchor,
				constant: Constraint.defaultSpace
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: safeArea.trailingAnchor,
				constant: -Constraint.defaultSpace
			),
			
			nextButton.leadingAnchor.constraint(
				equalTo: view.leadingAnchor,
				constant: Constraint.defaultSpace
			),
			nextButton.trailingAnchor.constraint(
				equalTo: view.trailingAnchor,
				constant: -Constraint.defaultSpace
			),
			nextButton.heightAnchor.constraint(equalToConstant: Constraint.buttonHeight),
			nextButtonBottomConstraints
		])
	}
}

// MARK: - KeyBoard Action
private extension AddCheckListTitleViewController {
	func setupKeyBoardEvent() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
	
	@objc func keyboardWillShow(_ sender: Notification) {
		guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		let keyboardHeight = keyboardFrame.cgRectValue.height
		
		UIView.animate(withDuration: 0.3) {
			self.titleTextFieldCenterYConstraint.constant = -(keyboardHeight / 2)
			self.nextButtonBottomConstraints.constant = -keyboardHeight
			self.view.layoutIfNeeded()
		}
	}
	
	@objc func keyboardWillHide(_ sender: Notification) {
		UIView.animate(withDuration: 0.3) {
			self.titleTextFieldCenterYConstraint.constant = 0
			self.nextButtonBottomConstraints.constant = 0
			self.view.layoutIfNeeded()
		}
	}
}

// MARK: - TextField Delegate
extension AddCheckListTitleViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		titleTextField.resignFirstResponder()
		return true
	}
}

private extension UIViewController {
	func setupKeyboardTapAction() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(Self.dismissKeyboard))
		tap.cancelsTouchesInView = true
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
