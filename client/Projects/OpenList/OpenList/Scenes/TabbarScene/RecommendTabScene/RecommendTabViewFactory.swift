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
}

final class RecommendTabComponent: Component<RecommendTabDependency> {
	fileprivate var categoryUseCase: CategoryUseCase {
		return parent.categoryUseCase
	}
	
	fileprivate var recommendCheckListUseCase: RecommendCheckListUseCase {
		return DefaultRecommendCheckListUseCase(checklistRepository: parent.checkListRepository)
	}
}

protocol RecommendTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class RecommendTabViewFactory: Factory<RecommendTabDependency>, RecommendTabFactoryable {
	override init(parent: RecommendTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let compoment = RecommendTabComponent(parent: parent)
		let router = RecommendTabRouter()
		let viewModel = RecommendTabModel(
			categoryUseCase: compoment.categoryUseCase,
			recommendCheckListUseCase: compoment.recommendCheckListUseCase
		)
		let viewController = RecommendTabViewController(
			router: router,
			viewModel: viewModel
		)
		return viewController
	}
}
