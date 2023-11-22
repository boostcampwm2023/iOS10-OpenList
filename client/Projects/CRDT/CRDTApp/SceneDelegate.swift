//
//  SceneDelegate.swift
//  CRDTApp
//
//  Created by 김영균 on 11/22/23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: windowScene)
		self.window?.makeKeyAndVisible()
		
		//		let rootViewController = StateBasedViewContoller()
		let rootViewController = OperationBasedViewController()
		self.window?.rootViewController = rootViewController
	}
}
