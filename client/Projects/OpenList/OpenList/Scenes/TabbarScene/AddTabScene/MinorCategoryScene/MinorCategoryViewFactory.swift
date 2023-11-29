//
//  MinorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol MinorCategoryDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
}

final class MinorCategoryComponent: Component<MinorCategoryDependency> {}

protocol MinorCategoryFactoryable: Factoryable {
	func make(_ mainCategory: CategoryItem, _ subCategory: CategoryItem) -> ViewControllable
}

final class MinorCategoryViewFactory: Factory<MinorCategoryDependency>, MinorCategoryFactoryable {
	override init(parent: MinorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(_ mainCategory: CategoryItem, _ subCategory: CategoryItem) -> ViewControllable {
		let router = MinorCategoryRouter()
		let viewModel = MinorCategoryViewModel(
			mainCategory: mainCategory,
			subCategory: subCategory,
			categoryUseCase: parent.categoryUseCase
		)
		let viewController = MinorCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
