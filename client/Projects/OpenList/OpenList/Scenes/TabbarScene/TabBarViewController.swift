//
//  TabBarViewController.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import UIKit

final class TabBarViewController: UITabBarController, ViewControllable {
	private let checkListTabFactoryable: CheckListTableFactoryable
	private let addTabFactoryable: AddCheckListTitleFactoryable
	private let recommendTabFactoryable: RecommendTabFactoryable
	
	init(
		checkListTabFactoryable: CheckListTableFactoryable,
		addTabFactoryable: AddCheckListTitleFactoryable,
		recommendTabFactoryable: RecommendTabFactoryable
	) {
		self.checkListTabFactoryable = checkListTabFactoryable
		self.addTabFactoryable = addTabFactoryable
		self.recommendTabFactoryable = recommendTabFactoryable
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		
		let emptyViewController = UIViewController()
		emptyViewController.view.backgroundColor = .systemBackground
		emptyViewController.tabBarItem = makeTabBarItem(of: .addTab)
		
		let checkListTabViewControllable = checkListTabFactoryable.make()
		let checkListTabNavigationController = makeTabNavigationController(of: checkListTabViewControllable)
		checkListTabNavigationController.navigationController.tabBarItem = makeTabBarItem(of: .checklistTab)
		
		let recommendTabViewControllable = recommendTabFactoryable.make()
		let recommendTabNavigationController = makeTabNavigationController(of: recommendTabViewControllable)
		recommendTabNavigationController.navigationController.tabBarItem = makeTabBarItem(of: .recommendTab)
		self.viewControllers = [
			checkListTabNavigationController.navigationController,
			emptyViewController,
			recommendTabNavigationController.navigationController
		]
		selectedIndex = TabBarPage.checklistTab.pageOrderNumber()
		view.backgroundColor = .systemBackground
		tabBar.backgroundColor = .systemBackground
		tabBar.tintColor = .primary1
	}
}

private extension TabBarViewController {
	func makeTabNavigationController(of scene: ViewControllable) -> NavigationControllable {
		let tabNavigationController = NavigationControllable(root: scene)
		tabNavigationController.navigationController.interactivePopGestureRecognizer?.isEnabled = true
		return tabNavigationController
	}
	
	func makeTabBarItem(of page: TabBarPage) -> UITabBarItem {
		return UITabBarItem(
			title: page.pageTitleValue(),
			image: .init(named: page.tabIconName()),
			tag: page.pageOrderNumber()
		)
	}
}

extension TabBarViewController: UITabBarControllerDelegate {
	func tabBarController(
		_ tabBarController: UITabBarController,
		shouldSelect viewController: UIViewController
	) -> Bool {
		if viewController.tabBarItem.tag == TabBarPage.addTab.pageOrderNumber() {
			let addTabViewControllable = addTabFactoryable.make()
			let addTabNavigationViewController = makeTabNavigationController(of: addTabViewControllable)
			present(addTabNavigationViewController.uiviewController, animated: true)
			return false
		} else {
			return true
		}
	}
}
