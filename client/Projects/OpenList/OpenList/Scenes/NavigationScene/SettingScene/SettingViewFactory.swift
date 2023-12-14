//
//  SettingViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import CustomNetwork
import Foundation

protocol SettingDependency: Dependency {
	var session: CustomSession { get }
	var checkListStorage: PrivateCheckListStorage { get }
}

final class SettingComponent: Component<SettingDependency> {
	var session: CustomSession { parent.session }
	
	var checkListStorage: PrivateCheckListStorage { parent.checkListStorage }
	
	fileprivate var settingRepository: SettingRepository {
		return DefaultSettingRepository(checkListStorage: checkListStorage, session: session)
	}
	
	fileprivate var settingUseCase: SettingUseCase {
		return DefaultSettingUseCase(settingRepository: settingRepository)
	}
}

protocol SettingFactoryable: Factoryable {
	func make(with parentRouter: AppRouterProtocol) -> ViewControllable
}

final class SettingViewFactory: Factory<SettingDependency>, SettingFactoryable {
	override init(parent: SettingDependency) {
		super.init(parent: parent)
	}
	
	func make(with appRouter: AppRouterProtocol) -> ViewControllable {
		let component = SettingComponent(parent: parent)
		let router = SettingRouter(appRouter: appRouter)
		let viewModel = SettingViewModel(settingUseCase: component.settingUseCase)
		let viewController = SettingViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
