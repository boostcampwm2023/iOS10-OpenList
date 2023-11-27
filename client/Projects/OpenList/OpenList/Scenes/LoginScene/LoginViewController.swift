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
	private let welcomeLabel: UILabel = .init()
	private let loginButton: UIButton = .init()
	
	// MARK: - Properties
	private let router: LoginRoutingLogic
	private let viewModel: any LoginViewModelable
	private var cancellables: Set<AnyCancellable> = []
	private let loginButtonTap: PassthroughSubject<LoginInfo, Never> = .init()
	
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
		setViewAttributes()
		setViewHierachies()
		setViewConstraints()
		bind()
	}
}

// MARK: - Bind Methods
extension LoginViewController: ViewBindable {
	typealias State = LoginState
	typealias OutputError = Error
	
	func bind() {
		let input = LoginInput(
			loginButtonTap: loginButtonTap
		)
		
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, output) in owner.render(output) }
			.store(in: &cancellables)
	}
	
	func render(_ state: State) {
		switch state {
		case .error:
			handleError()
		case .success:
			router.routeToTabBarScene()
		}
	}
	
	func handleError() {}
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
	
	func checkName(nameContent: PersonNameComponents?) -> String {
		guard let content = nameContent else { return "" }
		
		guard let familyName = content.familyName,
			let givenName = content.givenName else { return "" }
		
		return familyName + givenName
	}
}

// MARK: - Auth Delegate
extension LoginViewController: ASAuthorizationControllerDelegate {
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) {
		switch authorization.credential {
		case let appleIDCredential as ASAuthorizationAppleIDCredential:
			guard
				let identityToken = appleIDCredential.identityToken,
				let authorizationCode = appleIDCredential.authorizationCode
				else { return }
			guard
				let identityTokenString = String(data: identityToken, encoding: .utf8),
				let authorizationCodeString = String(data: authorizationCode, encoding: .utf8)
				else { return }
			let fullName = checkName(nameContent: appleIDCredential.fullName)
			let loginInfo = LoginInfo(
				identityToken: identityTokenString,
				authorizationCode: authorizationCodeString,
				fullName: fullName
			)
			loginButtonTap.send(loginInfo)
		case let passwordCredential as ASPasswordCredential:
			_ = passwordCredential.user
			_ = passwordCredential.password
		default:
			break
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		// alert View
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
		view.backgroundColor = .systemBackground
		setWelcomeLabel()
		setLoginButton()
	}
	
	func setWelcomeLabel() {
		welcomeLabel.numberOfLines = 0
		welcomeLabel.textAlignment = .center
		welcomeLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .extra)
		welcomeLabel.text = "오리가 되신 걸 환영합니다"
		welcomeLabel.textColor = .label
	}
	
	func setLoginButton() {
		loginButton.layer.cornerRadius = 25
		loginButton.backgroundColor = .label
		loginButton.setImage(UIImage(systemName: "applelogo"), for: .normal)
		loginButton.setTitle("  Sign in with Apple", for: .normal)
		loginButton.setTitleColor(.background, for: .normal)
		loginButton.titleLabel?.font = UIFont.notoSansCJKkr(type: .regular, size: .medium)
		loginButton.imageView?.tintColor = .background
		loginButton.layer.borderWidth = 0.5
		loginButton.addTarget(self, action: #selector(authorizationButtonTapped), for: .touchUpInside)
	}
	
	func setViewHierachies() {
		[
			welcomeLabel,
			loginButton
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			
			loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
			loginButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
			loginButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
			loginButton.heightAnchor.constraint(equalToConstant: 50)
		])
	}
}
