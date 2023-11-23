//
//  LoginRouter.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

final class LoginRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension LoginRouter: LoginRoutingLogic {}
