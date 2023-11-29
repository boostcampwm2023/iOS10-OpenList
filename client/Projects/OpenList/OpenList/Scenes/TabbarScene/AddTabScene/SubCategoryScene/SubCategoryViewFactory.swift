//
//  SubCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol SubCategoryDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
}

final class SubCategoryComponent: Component<SubCategoryDependency>, MinorCategoryDependency {
	var categoryUseCase: CategoryUseCase {
		return parent.categoryUseCase
	}
	
	fileprivate var minorCategoryFactory: MinorCategoryFactoryable {
		return MinorCategoryViewFactory(parent: self)
	}
}

protocol SubCategoryFactoryable: Factoryable {
	func make(with category: CategoryItem) -> ViewControllable
}

final class SubCategoryViewFactory: Factory<SubCategoryDependency>, SubCategoryFactoryable {
	override init(parent: SubCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with category: CategoryItem) -> ViewControllable {
		let component = SubCategoryComponent(parent: parent)
		let router = SubCategoryRouter(minorCategoryFactory: component.minorCategoryFactory)
		let viewModel = SubCategoryViewModel(
			mainCategoryItem: category,
			categoryUseCase: parent.categoryUseCase
		)
		let viewController = SubCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
