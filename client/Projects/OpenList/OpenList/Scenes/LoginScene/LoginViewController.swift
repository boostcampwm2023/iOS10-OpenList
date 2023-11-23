//
//  LoginViewController.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import AuthenticationServices
import Combine
import UIKit

protocol LoginRoutingLogic: AnyObject {
	func routeToTabBarScene()
}

final class LoginViewController: UIViewController, ViewControllable {
	// MARK: - UI Components
	private let authorizationButton = ASAuthorizationAppleIDButton()
	
	// MARK: - Properties
	private let router: LoginRoutingLogic
	private let viewModel: any LoginViewModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - Initializers
	init(
		router: LoginRoutingLogic,
		viewModel: some LoginViewModelable
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
		self.view.backgroundColor = .systemBackground
		setViewAttributes()
		setViewHierachies()
		setViewConstraints()
		self.bind()
	}
}

// MARK: - Bind Methods
extension LoginViewController: ViewBindable {
	typealias State = LoginState
	typealias OutputError = Error
	
	func bind() {
	}
	
	func render(_ state: State) {
		switch state {
		default: break
		}
	}
	
	func handleError(_ error: OutputError) {
	}
}

// MARK: - Helper
private extension LoginViewController {
	@objc func authorizationButtonTapped() {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
}

extension LoginViewController: ASAuthorizationControllerDelegate {
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) {
		switch authorization.credential {
		case let appleIDCredential as ASAuthorizationAppleIDCredential:
				let userIdentifier = appleIDCredential.user
				let fullName = appleIDCredential.fullName
				let email = appleIDCredential.email
				// viewModel 로직 -> 
				// keyChain 로직 ->
				router.routeToTabBarScene()
		case let passwordCredential as ASPasswordCredential:
				let username = passwordCredential.user
				let password = passwordCredential.password
				// viewModel 로직
				// keyChain 로직
				router.routeToTabBarScene()
		default:
			break
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		print("Login Failed")
	}
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window!
	}
}

// MARK: - UI Configure
private extension LoginViewController {
	func setViewAttributes() {
		authorizationButton.addTarget(self, action: #selector(authorizationButtonTapped), for: .touchUpInside)
	}
	
	func setViewHierachies() {
		[
			authorizationButton
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}
}
