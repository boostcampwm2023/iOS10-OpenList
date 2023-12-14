//
//  SceneDelegate.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import AuthenticationServices
import Combine
import CustomNetwork
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
		let loginViewFactory = LoginViewFactory(parent: component)
		let appRootRouter = AppRouter(
			window: window,
			tabBarFactoryable: tabBarViewFactory,
			loginFactoryable: loginViewFactory
		)
		
		if isValidRefreshToken() {
			appRootRouter.showTapFlow()
		} else {
			appRootRouter.showLoginFlow()
		}
		
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
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard url.host() == SharedCheckListDeepLinkConstant.host else { return }
		guard let scheme = url.scheme, scheme == SharedCheckListDeepLinkConstant.scheme else { return }
		guard let queryItems = components?.queryItems else { return }
		guard let idString = queryItems.first(
			where: { $0.name == SharedCheckListDeepLinkConstant.query }
		)?.value
		else { return }
		guard let id = UUID(uuidString: idString) else { return }
		Task {
			let canParticipate = await canParticipateRoom(at: idString)
			if canParticipate {
				deepLinkSubject.send(.routeToSharedCheckList(id: id))
			}
		}
	}
	
	func canParticipateRoom(at cid: String) async -> Bool {
		print(cid)
		var builder = URLRequestBuilder(url: "https://openlist.kro.kr/shared-checklists/\(cid)/editors")
		builder.setMethod(.post)
		builder.addHeader(field: "Content-Type", value: "application/json")
		let session = CustomSession(interceptor: AccessTokenInterceptor())
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		do {
			let data = try await service.request()
			print(try JSONSerialization.jsonObject(with: data))
			return true
		} catch {
			return false
		}
	}
	
	func isValidRefreshToken() -> Bool {
		guard let refreshToken = KeyChain.shared.read(key: AuthKey.refreshToken) else { return false }
		var payload64 = refreshToken.components(separatedBy: ".")[1]
		
		while payload64.count % 4 != 0 {
			payload64 += "="
		}
		
		guard
			let payloadData = Data(base64Encoded: payload64, options: .ignoreUnknownCharacters),
			let json = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
			let exp = json["exp"] as? Int
		else { return false }
		
		let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
		let isValid = expDate.compare(Date()) == .orderedDescending
		
		return isValid
	}
}
