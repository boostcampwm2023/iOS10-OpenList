//
//  SettingViewController.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Combine
import UIKit

protocol SettingRoutingLogic: AnyObject {
	func dismissSettingScene()
}

final class SettingViewController: UIViewController, ViewControllable {
	enum Constant {
		static let title: String = "설정"
		static let previousTitle: String = "카테고리"
		static let settingItemHeight: CGFloat = 60
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndSetting: CGFloat = 24
	}
	
	// MARK: - Properties
  private let router: SettingRoutingLogic
  private let viewModel: any SettingViewModelable
  private var cancellables: Set<AnyCancellable> = []
	private var dataSource: [SettingItem] = []
	
	// UI Components
	private let settingView: UITableView = .init()
	private let navigationBar = OpenListNavigationBar(isBackButtonHidden: false, backButtonTitle: Constant.previousTitle)
	private let titleHaederView: TitleHeaderView = .init()
	
	// Event Properties
	private let viewLoad: PassthroughSubject<Void, Never> = .init()

  // MARK: - Initializers
	init(
		router: SettingRoutingLogic,
		viewModel: some SettingViewModelable
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
extension SettingViewController: ViewBindable {
	typealias State = SettingState
	typealias OutputError = Error

	func bind() {
		let input = SettingInput(viewDidLoad: viewLoad)
		let state = viewModel.transform(input)
		state
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .reload(let items):
			dataSource = items
			settingView.reloadData()
		}
	}

	func handleError(_ error: OutputError) {
		dump(error)
	}
}

// MARK: - View Methods
private extension SettingViewController {
	func setViewAttributes() {
		view.backgroundColor = UIColor.background
		
		setNavigationAttributes()
		setSettingViewAttributes()
		setHeaderViewAttributes()
	}
	
	func setNavigationAttributes() {
		navigationBar.delegate = self
	}
	
	func setSettingViewAttributes() {
		settingView.translatesAutoresizingMaskIntoConstraints = false
		settingView.separatorStyle = .none
		settingView.registerCell(SettingTableViewCell.self)
		settingView.delegate = self
		settingView.dataSource = self
	}
	
	func setHeaderViewAttributes() {
		titleHaederView.translatesAutoresizingMaskIntoConstraints = false
		titleHaederView.configure(title: Constant.title)
	}
	
	func setViewHierarchies() {
		view.addSubview(settingView)
		view.addSubview(navigationBar)
		view.addSubview(titleHaederView)
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleHaederView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			titleHaederView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			titleHaederView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			
			settingView.topAnchor.constraint(
				equalTo: titleHaederView.bottomAnchor,
				constant: Constant.spacingBetweenTitleAndSetting
			),
			settingView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
			settingView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			settingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
		])
	}
}

extension SettingViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) {
		router.dismissSettingScene()
	}
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) { }
}

extension SettingViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(SettingTableViewCell.self, for: indexPath)
		let item = dataSource[indexPath.row]
		cell.configure(with: item)
		cell.selectionStyle = .none
		return cell
	}
}

extension SettingViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		Constant.settingItemHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			dump("로그아웃")
		case 1:
			dump("회원탈퇴")
		default: return
		}
	}
}
