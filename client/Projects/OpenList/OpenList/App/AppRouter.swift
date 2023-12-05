//
//  AppRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

protocol AppRouterProtocol {
	func showTapFlow()
	func showLoginFlow()
}

final class AppRouter: AppRouterProtocol {
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
		let tabBarController = tabBarFactoryable.make(with: self)
		self.window?.rootViewController = tabBarController.uiviewController
	}
	
	func showLoginFlow() {
		let loginViewController = loginFactoryable.make(with: self)
		self.window?.rootViewController = loginViewController.uiviewController
	}
}
