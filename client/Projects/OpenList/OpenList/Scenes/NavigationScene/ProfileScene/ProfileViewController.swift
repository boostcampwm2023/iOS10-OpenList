//
//  ProfileViewController.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import UIKit
import Combine

protocol ProfileRoutingLogic: AnyObject {
	func dismissProfileScene()
}

final class ProfileViewController: UIViewController, ViewControllable {
	enum Constant {
		static let title: String = "프로필"
		static let previousTitle: String = "카테고리"
		static let settingItemHeight: CGFloat = 60
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndSetting: CGFloat = 24
	}
	
	// MARK: - Properties
	private let router: ProfileRoutingLogic
	private let viewModel: any ProfileViewModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// UI Components
	private let navigationBar = OpenListNavigationBar(isBackButtonHidden: false, backButtonTitle: Constant.previousTitle)
	private let titleHaederView: TitleHeaderView = .init()
	
	// Event Properties
	private let viewLoad: PassthroughSubject<Void, Never> = .init()

	// MARK: - Initializers
	init(
		router: ProfileRoutingLogic,
		viewModel: some ProfileViewModelable
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
		let input = ProfileInput(viewDidLoad: viewLoad)
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
			dump(user)
		}
	}

	func handleError(_ error: OutputError) {
		dump(error)
	}
}

// MARK: - View Methods
private extension ProfileViewController {
	func setViewAttributes() {
		view.backgroundColor = UIColor.background
		
		setNavigationAttributes()
		setHeaderViewAttributes()
	}
	
	func setNavigationAttributes() {
		navigationBar.delegate = self
	}
	
	func setHeaderViewAttributes() {
		titleHaederView.translatesAutoresizingMaskIntoConstraints = false
		titleHaederView.configure(title: Constant.title)
	}
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(titleHaederView)
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleHaederView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			titleHaederView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			titleHaederView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
		])
	}
}

extension ProfileViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) {
		router.dismissProfileScene()
	}
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) { }
}
