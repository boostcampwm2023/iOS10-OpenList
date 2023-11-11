//
//  AppRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

final class AppRouter {
	var window : UIWindow?
	var tabBarFactoryable: TabBarFactoryable
	
	init(window: UIWindow?, tabBarFactoryable: TabBarFactoryable) {
		self.window = window
		self.tabBarFactoryable = tabBarFactoryable
	}
	
	func showTapFlow() {
		let tabBarController = tabBarFactoryable.make()
		self.window?.rootViewController = tabBarController.uiviewController
	}
}
