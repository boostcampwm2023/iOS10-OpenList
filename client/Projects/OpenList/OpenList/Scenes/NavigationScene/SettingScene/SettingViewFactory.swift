//
//  SettingViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Foundation

protocol SettingDependency: Dependency { }

final class SettingComponent: Component<SettingDependency> { }

protocol SettingFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class SettingViewFactory: Factory<SettingDependency>, SettingFactoryable {
	override init(parent: SettingDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = SettingRouter()
		let viewModel = SettingViewModel()
		let viewController = SettingViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
