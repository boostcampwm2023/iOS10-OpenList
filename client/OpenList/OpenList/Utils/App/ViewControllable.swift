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
	}
}

final class TabBarControllable: ViewControllable {
	var uiviewController: UIViewController { return self.tabBarController }
	var tabBarController: UITabBarController
	
	init(tabBarController: UITabBarController = UITabBarController()) {
		self.tabBarController = tabBarController
	}
}
