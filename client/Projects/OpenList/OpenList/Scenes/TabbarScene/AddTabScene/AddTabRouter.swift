//
//  AddTabRouter.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class AddTabRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension AddTabRouter: AddTabRoutingLogic {
	func dismissScene() {
		viewController?.uiviewController.dismiss(animated: true, completion: {
			NotificationCenter.default.post(name: OpenListNotificationName.checkListAdded, object: self)
		})
	}
}

enum OpenListNotificationName {
	static let checkListAdded: Notification.Name = Notification.Name(rawValue: "checkListAdded")
}
