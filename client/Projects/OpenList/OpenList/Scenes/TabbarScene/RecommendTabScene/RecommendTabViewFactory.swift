//
//  RecommendTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol RecommendTabDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
	var checkListRepository: CheckListRepository { get }
	var profileFactoryable: ProfileFactoryable { get }
	var settingFactoryable: SettingFactoryable { get }
}

final class RecommendTabComponent: Component<RecommendTabDependency> {
	fileprivate var categoryUseCase: CategoryUseCase { parent.categoryUseCase }
	
	fileprivate var recommendCheckListUseCase: RecommendCheckListUseCase {
		return DefaultRecommendCheckListUseCase(checklistRepository: parent.checkListRepository)
	}
	
	fileprivate var profileFactoryable: ProfileFactoryable { parent.profileFactoryable }
	
	fileprivate var settingFactoryable: SettingFactoryable { parent.settingFactoryable }
}

protocol RecommendTabFactoryable: Factoryable {
	func make(with appRouter: AppRouterProtocol) -> ViewControllable
}

final class RecommendTabViewFactory: Factory<RecommendTabDependency>, RecommendTabFactoryable {
	override init(parent: RecommendTabDependency) {
		super.init(parent: parent)
	}
	
	func make(with appRouter: AppRouterProtocol) -> ViewControllable {
		let component = RecommendTabComponent(parent: parent)
		let router = RecommendTabRouter(
			appRouter: appRouter,
			profileFactory: component.profileFactoryable,
			settingFactory: component.settingFactoryable
		)
		let viewModel = RecommendTabModel(
			categoryUseCase: component.categoryUseCase,
			recommendCheckListUseCase: component.recommendCheckListUseCase
		)
		let viewController = RecommendTabViewController(
			router: router,
			viewModel: viewModel
		)
		router.viewController = viewController
		return viewController
	}
}
