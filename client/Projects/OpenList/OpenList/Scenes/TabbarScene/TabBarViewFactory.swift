//
//  TabBarViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

protocol TabBarDependency: Dependency {}

final class TabBarComponent:
	Component<TabBarDependency>,
	CheckListTableDependency,
	AddTabDependency,
	RecommendTabDependency {
	var sampleRepository: SampleRepository {
		return DefaultSampleRepository()
	}
	
	fileprivate var addTabFactoryable: AddTabFactoryable {
		return AddTabViewFactory(parent: self)
	}
	
	fileprivate var checklistTabFactoryable: CheckListTableFactoryable {
		return CheckListTableViewFactory(parent: self)
	}
	
	fileprivate var recommendTabFactoryable: RecommendTabFactoryable {
		return RecommendTabViewFactory(parent: self)
	}
}

protocol TabBarFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class TabBarViewFactory: Factory<TabBarDependency>, TabBarFactoryable {
	override init(parent: TabBarDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = TabBarComponent(parent: parent)
		let tabBarController = setTabViewControllers(component: component)
		return tabBarController
	}
}

private extension TabBarViewFactory {
	func setTabViewControllers(component: TabBarComponent) -> TabBarControllable {
		let addTabScene = component.addTabFactoryable.make()
		let checkListTabScene = component.checklistTabFactoryable.make()
		let recommendTabScene = component.recommendTabFactoryable.make()
		
		let addTabNavigationController = configureTabNavigationController(of: addTabScene)
		let checkListTabNavigationController = configureTabNavigationController(of: checkListTabScene)
		let recommendTabNavigationController = configureTabNavigationController(of: recommendTabScene)
		
		addTabNavigationController.navigationController.tabBarItem = configureTabBarItem(of: .addTab)
		checkListTabNavigationController.navigationController.tabBarItem = configureTabBarItem(of: .checklistTab)
		recommendTabNavigationController.navigationController.tabBarItem = configureTabBarItem(of: .recommendTab)
		
		let navigationControllers = [
			checkListTabNavigationController, addTabNavigationController, recommendTabNavigationController
		]
		let tabBarControllable = TabBarControllable()
		tabBarControllable.tabBarController.viewControllers = navigationControllers.map { $0.navigationController }
		tabBarControllable.tabBarController.selectedIndex = TabBarPage.checklistTab.pageOrderNumber()
		tabBarControllable.tabBarController.view.backgroundColor = .systemBackground
		tabBarControllable.tabBarController.tabBar.backgroundColor = .systemBackground
		tabBarControllable.tabBarController.tabBar.tintColor = .black
		
		return tabBarControllable
	}
	
	func configureTabNavigationController(of scene: ViewControllable) -> NavigationControllable {
		let tabNavigationController = NavigationControllable(root: scene)
		tabNavigationController.navigationController.interactivePopGestureRecognizer?.isEnabled = true
		return tabNavigationController
	}
	
	func configureTabBarItem(of page: TabBarPage) -> UITabBarItem {
		return UITabBarItem(
			title: page.pageTitleValue(),
			image: nil,
			tag: page.pageOrderNumber()
		)
	}
}