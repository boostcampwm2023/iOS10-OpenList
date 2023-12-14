//
//  ProfileViewController.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Combine
import UIKit

protocol ProfileRoutingLogic: AnyObject {
	func dismissProfileScene()
}

final class ProfileViewController: UIViewController, ViewControllable {
	enum Constant {
		static let title: String = "프로필"
		static let previousTitle: String = "카테고리"
		static let horizontalPadding: CGFloat = 20
		static let profileImageWidthHeight: CGFloat = 100
		static let inputViewWidth: CGFloat = 200
		static let inputViewHeight: CGFloat = 28
		static let editImageWidthHeight: CGFloat = 24
		static let spacingBetweenTitleAndSetting: CGFloat = 24
		static let spacingBetweenProfileAndNickname: CGFloat = 40
		static let spacingBetweenNicknameAndLine: CGFloat = 8
	}
	
	// MARK: - Properties
	private let router: ProfileRoutingLogic
	private let viewModel: any ProfileViewModelable & ProfileViewModelDataSource
	private var cancellables: Set<AnyCancellable> = []
	
	
	// UI Components
	private let navigationBar = OpenListNavigationBar(isBackButtonHidden: false, backButtonTitle: Constant.previousTitle)
	private let titleHaederView: TitleHeaderView = .init()
	private let profileImageView: UIImageView = .init()
	private let nicknameInputView: UIView = .init()
	private let nicknameLabel: UILabel = .init()
	private let editImageView: UIImageView = .init()
	private let lineView: UIView = .init()
	
	// Event Properties
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let updateNickname: PassthroughSubject<String, Never> = .init()

	// MARK: - Initializers
	init(
		router: ProfileRoutingLogic,
		viewModel: some ProfileViewModelable & ProfileViewModelDataSource
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
		setViewHierarchies()
		setViewConstraints()
		bind()
		viewLoad.send()
	}
}

// MARK: - Bind Methods
extension ProfileViewController: ViewBindable {
	typealias State = ProfileState
	typealias OutputError = Error

	func bind() {
		let input = ProfileInput(
			viewDidLoad: viewLoad,
			updateNickname: updateNickname
		)
		let state = viewModel.transform(input)
		state
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .viewDidLoad(let user):
			nicknameLabel.text = user.nickname
		case .updateNickname(let nickname):
			nicknameLabel.text = nickname
		}
	}

	func handleError(_ error: OutputError) {
		dump(error)
	}
}

private extension ProfileViewController {
	@objc func inputNickname() {
		AlertBuilder(viewController: self)
			.setTitle("이름")
			.setPlaceholder("이름을 입력해주세요.")
			.setTextFieldText(viewModel.nickname)
			.addActionConfirm("확인") { [weak self] text in
				self?.updateNickname.send(text)
			}
			.addActionCancel("취소")
			.show()
	}
}

// MARK: - View Methods
private extension ProfileViewController {
	func setViewAttributes() {
		view.backgroundColor = .background
		
		setNavigationAttributes()
		setHeaderViewAttributes()
		setProfileImageViewAttributes()
		setNicknameInputViewAttributes()
		setNicknameLabelAttributes()
		setLineViewAttributes()
		setEditImageViewAttributes()
	}
	
	func setNavigationAttributes() {
		navigationBar.delegate = self
	}
	
	func setHeaderViewAttributes() {
		titleHaederView.translatesAutoresizingMaskIntoConstraints = false
		titleHaederView.configure(title: Constant.title)
	}
	
	func setProfileImageViewAttributes() {
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
		profileImageView.image = .profile.withTintColor(.primary1, renderingMode: .alwaysOriginal)
	}
	
	func setNicknameInputViewAttributes() {
		nicknameInputView.translatesAutoresizingMaskIntoConstraints = false
		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(inputNickname))
		tapGesture.numberOfTapsRequired = 1
		nicknameInputView.isUserInteractionEnabled = true
		nicknameInputView.addGestureRecognizer(tapGesture)
	}
	
	func setNicknameLabelAttributes() {
		nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
		nicknameLabel.font = .notoSansCJKkr(type: .regular, size: .small)
		nicknameLabel.textAlignment = .center
	}
	
	func setLineViewAttributes() {
		lineView.translatesAutoresizingMaskIntoConstraints = false
		lineView.backgroundColor = .gray1
	}
	
	func setEditImageViewAttributes() {
		editImageView.translatesAutoresizingMaskIntoConstraints = false
		editImageView.image = .edit.withTintColor(.gray1, renderingMode: .alwaysOriginal)
	}
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(titleHaederView)
		view.addSubview(profileImageView)
		view.addSubview(nicknameInputView)
		nicknameInputView.addSubview(nicknameLabel)
		nicknameInputView.addSubview(lineView)
		nicknameInputView.addSubview(editImageView)
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleHaederView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			titleHaederView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			titleHaederView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			
			profileImageView.widthAnchor.constraint(equalToConstant: Constant.profileImageWidthHeight),
			profileImageView.heightAnchor.constraint(equalToConstant: Constant.profileImageWidthHeight),
			profileImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
			
			nicknameInputView.widthAnchor.constraint(equalToConstant: Constant.inputViewWidth),
			nicknameInputView.heightAnchor.constraint(equalToConstant: Constant.inputViewHeight),
			nicknameInputView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
			nicknameInputView.centerYAnchor.constraint(
				equalTo: safeArea.centerYAnchor,
				constant: Constant.spacingBetweenProfileAndNickname
			),
			nicknameInputView.topAnchor.constraint(
				equalTo: profileImageView.bottomAnchor,
				constant: Constant.spacingBetweenProfileAndNickname
			),
			
			nicknameLabel.leadingAnchor.constraint(
				equalTo: nicknameInputView.leadingAnchor,
				constant: Constant.editImageWidthHeight
			),
			nicknameLabel.topAnchor.constraint(equalTo: nicknameInputView.topAnchor),
			nicknameLabel.bottomAnchor.constraint(
				equalTo: lineView.topAnchor,
				constant: -Constant.spacingBetweenNicknameAndLine
			),
			
			lineView.heightAnchor.constraint(equalToConstant: 1),
			lineView.leadingAnchor.constraint(equalTo: nicknameInputView.leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: nicknameInputView.trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: nicknameInputView.bottomAnchor),
			
			editImageView.topAnchor.constraint(equalTo: nicknameInputView.topAnchor),
			editImageView.widthAnchor.constraint(equalToConstant: Constant.editImageWidthHeight),
			editImageView.heightAnchor.constraint(equalToConstant: Constant.editImageWidthHeight),
			editImageView.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor),
			editImageView.trailingAnchor.constraint(equalTo: nicknameInputView.trailingAnchor)
		])
	}
}

extension ProfileViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) {
		router.dismissProfileScene()
	}
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) { }
}
