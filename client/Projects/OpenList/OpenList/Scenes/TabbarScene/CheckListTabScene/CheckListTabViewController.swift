//
//  CheckListTabViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

enum CheckListTabType: Int, Comparable {
	case privateTab
	case withTab
	case sharedTab
	
	static func < (lhs: CheckListTabType, rhs: CheckListTabType) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

protocol CheckListTabRoutingLogic: AnyObject {
	func showProfile()
	func showSetting()
}

final class CheckListTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
	private var currentTab: CheckListTabType = .privateTab {
		didSet {
			paging(from: oldValue, to: currentTab)
		}
	}
	private let router: CheckListTabRoutingLogic
	
	// MARK: - UI Components
	/// 네비게이션 뷰 컨트롤러
	private let navigationBar: OpenListNavigationBar = .init(leftItems: [.profile], rightItems: [.more])
	/// 상단 탭 뷰
	private let checkListTopTabView: CheckListTopTabView = .init()
	/// 상단 탭의 인디케이터 뷰
	private let indicatorView: UIView = .init()
	/// 상단 탭의 컨텐츠를 보여주는 페이징 뷰
	private let pageViewController = UIPageViewController(
		transitionStyle: .scroll,
		navigationOrientation: .horizontal,
		options: nil
	)
	// 상단 탭의 컨텐츠 뷰 컨트롤러
	private let privateCheckListTableFactory: CheckListTableFactoryable
	private let withCheckListFactoryable: WithCheckListFactoryable
	private let sharedCheckListFactory: SharedCheckListFactoryable
	private var childCheckListViewControllers: [UIViewController] = []
	/// 인디케이터 뷰 센터 레이아웃
	private var indicatorViewCenterConstraint: NSLayoutConstraint?
	
	// MARK: - Initializers
	init(
		router: CheckListTabRoutingLogic,
		privateCheckListTableFactory: CheckListTableFactoryable,
		withCheckListFactoryable: WithCheckListFactoryable,
		sharedCheckListFactory: SharedCheckListFactoryable
	) {
		self.router = router
		self.privateCheckListTableFactory = privateCheckListTableFactory
		self.withCheckListFactoryable = withCheckListFactoryable
		self.sharedCheckListFactory = sharedCheckListFactory
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		setChildViewControllers()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
}

// MARK: - View Methods
private extension CheckListTabViewController {
	func setChildViewControllers() {
		let privateCheckListTableViewControllable = privateCheckListTableFactory.make()
		let withCheckListViewControllable = withCheckListFactoryable.make()
		let sharedCheckListViewControllable = sharedCheckListFactory.make()
		childCheckListViewControllers.append(privateCheckListTableViewControllable.uiviewController)
		childCheckListViewControllers.append(withCheckListViewControllable.uiviewController)
		childCheckListViewControllers.append(sharedCheckListViewControllable.uiviewController)
	}
	
	func setViewAttributes() {
		view.backgroundColor = .background
		setCheckListTopViewAttributes()
		setPageViewControllerAttributes()
		setIndicatorViewAttributes()
		setNavigationBarAttributes()
	}
	
	func setCheckListTopViewAttributes() {
		checkListTopTabView.translatesAutoresizingMaskIntoConstraints = false
		checkListTopTabView.delegate = self
	}
	
	func setPageViewControllerAttributes() {
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.delegate = self
		pageViewController.dataSource = self
		guard let folderViewController = childCheckListViewControllers.first else { return }
		pageViewController.setViewControllers([folderViewController], direction: .forward, animated: true, completion: nil)
	}
	
	func setIndicatorViewAttributes() {
		indicatorView.translatesAutoresizingMaskIntoConstraints = false
		indicatorView.backgroundColor = .primary1
		indicatorView.layer.cornerRadius = 1
	}
	
	func setNavigationBarAttributes() {
		navigationBar.delegate = self
	}
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(checkListTopTabView)
		view.addSubview(indicatorView)
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
	}
	
	func setViewConstraints() {
		let indicatorViewCenterConstraint = indicatorView.centerXAnchor.constraint(
			equalTo: checkListTopTabView.privateTabButton.centerXAnchor
		)
		self.indicatorViewCenterConstraint = indicatorViewCenterConstraint
		
		NSLayoutConstraint.activate([
			checkListTopTabView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			checkListTopTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
			checkListTopTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
			checkListTopTabView.heightAnchor.constraint(equalToConstant: 40),
			
			indicatorViewCenterConstraint,
			indicatorView.topAnchor.constraint(equalTo: checkListTopTabView.bottomAnchor, constant: 4),
			indicatorView.widthAnchor.constraint(equalToConstant: 44),
			indicatorView.heightAnchor.constraint(equalToConstant: 2),
			
			pageViewController.view.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 24),
			pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		pageViewController.didMove(toParent: self)
	}
}

// MARK: - UIPageViewController DataSource & Delegate
extension CheckListTabViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard let index = childCheckListViewControllers.firstIndex(of: viewController) else { return nil }
		let previousIndex = index - 1
		guard previousIndex >= 0 else { return nil }
		return childCheckListViewControllers[previousIndex]
	}
	
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard let index = childCheckListViewControllers.firstIndex(of: viewController) else { return nil }
		let afterIndex = index + 1
		guard afterIndex < childCheckListViewControllers.count else { return nil }
		return childCheckListViewControllers[afterIndex]
	}
	
	// 페이지 컨트롤러로 페이징 후 호출되는 메서드
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		guard let currentVC = pageViewController.viewControllers?.first,
			let currentIndex = childCheckListViewControllers.firstIndex(of: currentVC),
			let currentTab = CheckListTabType(rawValue: currentIndex)
		else { return }
		// 상단 탭의 선택 상태를 변경
		checkListTopTabView.setSelectedTab(currentTab)
		// 페이징 뷰 컨트롤러의 현재 탭 상태를 변경
		self.currentTab = currentTab
	}
}

// MARK: - CheckListTopTabView Delegate
extension CheckListTabViewController: CheckListTopTabViewDelegate {
	func checkListTopTabView(_ checkListTopTabView: CheckListTopTabView, tabDidSelect tab: CheckListTabType) {
		currentTab = tab
		moveToTab(tab)
	}
}

// MARK: - 탭 전환 메서드
private extension CheckListTabViewController {
	func paging(from oldTab: CheckListTabType, to newTab: CheckListTabType) {
		// collectionView 에서 선택한 경우
		let direction: UIPageViewController.NavigationDirection = oldTab < newTab ? .forward : .reverse
		pageViewController.setViewControllers(
			[childCheckListViewControllers[currentTab.rawValue]],
			direction: direction,
			animated: true,
			completion: nil
		)
		moveToTab(newTab)
		// pageViewController에서 paging한 경우
	}
	
	func moveToTab(_ tab: CheckListTabType) {
		switch tab {
		case .privateTab: moveToPrivateTab()
		case .withTab: moveToWithTab()
		case .sharedTab: moveToShareTab()
		}
	}
	
	func moveToPrivateTab() {
		var newIndicatorViewCenterconstraint: NSLayoutConstraint
		newIndicatorViewCenterconstraint = indicatorView.centerXAnchor.constraint(
			equalTo: checkListTopTabView.privateTabButton.centerXAnchor
		)
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3) {
			self.indicatorViewCenterConstraint?.isActive = false
			self.indicatorViewCenterConstraint = newIndicatorViewCenterconstraint
			self.indicatorViewCenterConstraint?.isActive = true
			self.view.layoutIfNeeded()
		}
	}
	
	func moveToWithTab() {
		var newIndicatorViewCenterconstraint: NSLayoutConstraint
		newIndicatorViewCenterconstraint = indicatorView.centerXAnchor.constraint(
			equalTo: checkListTopTabView.withTabButton.centerXAnchor
		)
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3) {
			self.indicatorViewCenterConstraint?.isActive = false
			self.indicatorViewCenterConstraint = newIndicatorViewCenterconstraint
			self.indicatorViewCenterConstraint?.isActive = true
			self.view.layoutIfNeeded()
		}
	}
	
	func moveToShareTab() {
		var newIndicatorViewCenterconstraint: NSLayoutConstraint
		newIndicatorViewCenterconstraint = indicatorView.centerXAnchor.constraint(
			equalTo: checkListTopTabView.sharedTabButton.centerXAnchor
		)
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3) {
			self.indicatorViewCenterConstraint?.isActive = false
			self.indicatorViewCenterConstraint = newIndicatorViewCenterconstraint
			self.indicatorViewCenterConstraint?.isActive = true
			self.view.layoutIfNeeded()
		}
	}
}

extension CheckListTabViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) { }
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) {
		switch item.type {
		case .profile:
			router.showProfile()
		case .more:
			router.showSetting()
		default: return
		}
	}
}
