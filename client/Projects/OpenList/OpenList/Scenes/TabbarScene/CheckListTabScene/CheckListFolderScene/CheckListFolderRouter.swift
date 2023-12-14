//
//  CheckListFolderRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Foundation

final class CheckListFolderRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension CheckListFolderRouter: CheckListFolderRoutingLogic { }
