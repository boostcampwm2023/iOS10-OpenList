//
//  ViewControllable.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import UIKit

protocol ViewControllable: AnyObject {
	var uiviewController: UIViewController { get }
}

extension ViewControllable {
	func pushViewController(_ viewControllable: ViewControllable, animated: Bool) {
		self.uiviewController.navigationController?.pushViewController(
			viewControllable.uiviewController,
			animated: animated
		)
	}
	
	func popViewController(animated: Bool) {
		self.uiviewController.navigationController?.popViewController(animated: animated)
	}
	
	func popToRootViewController(animated: Bool) {
		self.uiviewController.navigationController?.popToRootViewController(animated: animated)
	}
}

extension ViewControllable where Self: UIViewController {
	var uiviewController: UIViewController {
		return self
	}
}

final class NavigationControllable: ViewControllable {
	var uiviewController: UIViewController { return self.navigationController }
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController = UINavigationController()) {
		self.navigationController = navigationController
	}
	
	init(root: ViewControllable) {
		self.navigationController = UINavigationController(rootViewController: root.uiviewController)
		navigationController.isNavigationBarHidden = true
	}
}

final class TabBarControllable: ViewControllable {
	var uiviewController: UIViewController { return self.tabBarController }
	var tabBarController: UITabBarController
	
	init(tabBarController: UITabBarController = CustomTabBarController()) {
		self.tabBarController = tabBarController
	}
}

final class CustomTabBarController: UITabBarController {
	private var index = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
	}
	
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		item.title == "추가" ? (index = false) : (index = true)
	}
}

extension CustomTabBarController: UITabBarControllerDelegate {
	func tabBarController(
		_ tabBarController: UITabBarController,
		shouldSelect viewController: UIViewController
	) -> Bool {
		if index == false {
			present(viewController, animated: true)
		}
		return index
	}
}
