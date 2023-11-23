//
//  SceneDelegate.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import AuthenticationServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()
		
		let navigationControllable = NavigationControllable(navigationController: UINavigationController())
		let component = AppComponent(navigationControllable: navigationControllable)
		let tabBarViewFactory = TabBarViewFactory(parent: component)
		let loginViewFactory = LoginViewFactory(parent: AppLoginComponent(navigationControllable: navigationControllable))
		let appRootRouter = AppRouter(
			window: window,
			tabBarFactoryable: tabBarViewFactory,
			loginFactoryable: loginViewFactory
		)
		//		appRootRouter.showTapFlow()
		appRootRouter.showLoginFlow()
	}
}
