//
//  SubCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol SubCategoryDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
	var addCheckListItemFactory: AddCheckListItemFactoryable { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class SubCategoryComponent:
	Component<SubCategoryDependency>,
	MinorCategoryDependency,
	AddCheckListItemDependency {
	var persistenceUseCase: PersistenceUseCase { parent.persistenceUseCase }
	
	var addCheckListItemFactory: AddCheckListItemFactoryable {
		return parent.addCheckListItemFactory
	}
	
	var categoryUseCase: CategoryUseCase {
		return parent.categoryUseCase
	}
	
	fileprivate var minorCategoryFactory: MinorCategoryFactoryable {
		return MinorCategoryViewFactory(parent: self)
	}
}

protocol SubCategoryFactoryable: Factoryable {
	func make(_ title: String, _ mainCategory: CategoryItem) -> ViewControllable
}

final class SubCategoryViewFactory: Factory<SubCategoryDependency>, SubCategoryFactoryable {
	override init(parent: SubCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(_ title: String, _ mainCategory: CategoryItem) -> ViewControllable {
		let component = SubCategoryComponent(parent: parent)
		let router = SubCategoryRouter(
			minorCategoryFactory: component.minorCategoryFactory,
			addCheckListItemFactory: component.addCheckListItemFactory
		)
		let viewModel = SubCategoryViewModel(
			title: title,
			mainCategoryItem: mainCategory,
			categoryUseCase: parent.categoryUseCase
		)
		let viewController = SubCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
