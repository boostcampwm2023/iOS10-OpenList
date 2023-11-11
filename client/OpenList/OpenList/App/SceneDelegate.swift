//
//  SceneDelegate.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()
		
		let navigationControllable = NavigationControllable(navigationController: UINavigationController())
		let component = AppComponent(navigationControllable: navigationControllable)
		let tabBarViewFactory = TabBarViewFactory(component: .init(parent: component))
		let appRootRouter = AppRouter(window: window, tabBarFactoryable: tabBarViewFactory)
		appRootRouter.showTapFlow()
	}
}