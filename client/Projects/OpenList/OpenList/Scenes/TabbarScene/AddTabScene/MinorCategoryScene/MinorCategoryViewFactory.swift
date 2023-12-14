//
//  MinorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol MinorCategoryDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
	var addCheckListItemFactory: AddCheckListItemFactoryable { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class MinorCategoryComponent:
	Component<MinorCategoryDependency>,
	AddCheckListItemDependency {
	var persistenceUseCase: PersistenceUseCase { parent.persistenceUseCase }
	
	var categoryUseCase: CategoryUseCase {
		return parent.categoryUseCase
	}
}

protocol MinorCategoryFactoryable: Factoryable {
	func make(_ title: String, _ mainCategory: CategoryItem, _ subCategory: CategoryItem) -> ViewControllable
}

final class MinorCategoryViewFactory: Factory<MinorCategoryDependency>, MinorCategoryFactoryable {
	override init(parent: MinorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(_ title: String, _ mainCategory: CategoryItem, _ subCategory: CategoryItem) -> ViewControllable {
		let router = MinorCategoryRouter(
			addCheckListItemFactory: parent.addCheckListItemFactory
		)
		let viewModel = MinorCategoryViewModel(
			title: title,
			mainCategory: mainCategory,
			subCategory: subCategory,
			categoryUseCase: parent.categoryUseCase
		)
		let viewController = MinorCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
