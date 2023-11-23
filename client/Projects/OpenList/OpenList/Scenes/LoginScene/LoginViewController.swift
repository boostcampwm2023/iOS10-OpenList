//
//  LoginViewController.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import UIKit
import Combine

import AuthenticationServices
import UIKit
import Combine

protocol LoginRoutingLogic: AnyObject {
	// TODO: 뷰 컨트롤러의 화면 이동 로직을 라우터에게 위임할 메소드를 작성합니다.
}

final class LoginViewController: UIViewController, ViewControllable {
	// MARK: - UI Components
	private let authorizationButton = ASAuthorizationAppleIDButton()
	
	// MARK: - Properties
	private let loginButtonTap: PassthroughSubject<Void, Never> = .init()
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
		self.bind()
	}
}

// MARK: - Bind Methods
extension LoginViewController: ViewBindable {
	typealias State = LoginState
	typealias OutputError = Error
	
	func bind() {
		let input = LoginInput(
			loginButtonTap: loginButtonTap.eraseToAnyPublisher()
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
				// TODO: 변화된 모델의 상태를 뷰에 반영합니다.
			default: break
		}
	}
	
	func handleError(_ error: OutputError) {
		// TODO: 에러 핸들링을 합니다.
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
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		switch authorization.credential {
				// 비밀번호 or FaceID 입력
			case let appleIDCredential as ASAuthorizationAppleIDCredential:
				let userIdentifier = appleIDCredential.user
				let fullName = appleIDCredential.fullName
				let email = appleIDCredential.email
				
				print(appleIDCredential.authorizationCode)
				print(appleIDCredential.identityToken)
				print(userIdentifier)
				print(fullName)
				print(email)
				// iCloud 연결
			case let passwordCredential as ASPasswordCredential:
				let username = passwordCredential.user
				let password = passwordCredential.password
				
				print(username)
				print(password)
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
