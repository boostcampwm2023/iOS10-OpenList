//
//  CheckListTableRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Foundation

final class CheckListTableRouter {
	weak var viewController: ViewControllable?
	private var privateCheckListDetailFactory: PrivateDetailCheckListFactoryable
	
	init(privateCheckListDetailFactory: PrivateDetailCheckListFactoryable) {
		self.privateCheckListDetailFactory = privateCheckListDetailFactory
	}
}

// MARK: - RoutingLogic
extension CheckListTableRouter: CheckListTableRoutingLogic {
	func routeToDetailScene(with id: UUID) {
		let detailCheckListViewControllable = privateCheckListDetailFactory.make(with: id)
		viewController?.pushViewController(detailCheckListViewControllable, animated: true)
	}
}
