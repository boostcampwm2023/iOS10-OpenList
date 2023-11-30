//
//  AddCheckListItemRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Foundation

final class AddCheckListItemRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension AddCheckListItemRouter: AddCheckListItemRoutingLogic {
	func routeToMinorCategoryView() {
		viewController?.popViewController(animated: true)
	}
	
	func dismiss() {
		viewController?.dismiss(animated: true, completion: {
			NotificationCenter.default.post(name: OpenListNotificationName.checkListAdded, object: nil)
		})
	}
}
