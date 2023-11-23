//
//  AppRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

final class AppRouter {
	var window: UIWindow?
	var tabBarFactoryable: TabBarFactoryable
	var loginFactoryable: LoginFactoryable
	
	init(
		window: UIWindow?,
		tabBarFactoryable: TabBarFactoryable,
		loginFactoryable: LoginFactoryable
	) {
		self.window = window
		self.tabBarFactoryable = tabBarFactoryable
		self.loginFactoryable = loginFactoryable
	}
	
	func showTapFlow() {
		let tabBarController = tabBarFactoryable.make()
		self.window?.rootViewController = tabBarController.uiviewController
	}
	
	func showLoginFlow() {
		let loginViewController = loginFactoryable.make()
		self.window?.rootViewController = loginViewController.uiviewController
	}
}
