//
//  SceneDelegate.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> = .init()
	
	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()
		
		let navigationControllable = NavigationControllable(navigationController: UINavigationController())
		let component = AppComponent(
			navigationControllable: navigationControllable,
			deepLinkSubject: deepLinkSubject
		)
		let tabBarViewFactory = TabBarViewFactory(parent: component)
		let appRootRouter = AppRouter(window: window, tabBarFactoryable: tabBarViewFactory)
		appRootRouter.showTapFlow()
		
		// 앱이 종료된 경우 Deeplink
		if let urlContext = connectionOptions.urlContexts.first {
			executeSharedCheckListDeepLink(urlContext.url)
		}
	}
	
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		executeSharedCheckListDeepLink(url)
	}
}

private extension SceneDelegate {
	enum SharedCheckListDeepLinkConstant {
		static let scheme = "openlist"
		static let host = "shared-checklists"
		static let query = "shared-checklistId"
	}
	
	func executeSharedCheckListDeepLink(_ url: URL) {
		guard url.host() == SharedCheckListDeepLinkConstant.host else { return }
		guard let scheme = url.scheme, scheme == SharedCheckListDeepLinkConstant.scheme else { return }
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard let queryItems = components?.queryItems else { return }
		guard let id = queryItems.first(where: { $0.name == SharedCheckListDeepLinkConstant.query })?.value else { return }
		deepLinkSubject.send(.routeToSharedCheckList(id: id))
	}
}
