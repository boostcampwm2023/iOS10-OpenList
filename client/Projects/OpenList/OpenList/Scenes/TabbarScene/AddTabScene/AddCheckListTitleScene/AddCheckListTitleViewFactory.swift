//
//  AddCheckListTitleViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import CustomNetwork
import Foundation

protocol AddCheckListTitleDependency: Dependency {
	var validCheckUseCase: ValidCheckUseCase { get }
	var persistenceUseCase: PersistenceUseCase { get }
	var categoryUseCase: CategoryUseCase { get }
}

final class AddCheckListTitleComponent:
	Component<AddCheckListTitleDependency>,
	MainCategoryDependency {
	var categoryUseCase: CategoryUseCase {
		return parent.categoryUseCase
	}
	
	fileprivate var validCheckUseCase: ValidCheckUseCase {
		return parent.validCheckUseCase
	}
	
	var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
	
	fileprivate var mainCategoryFactoryable: MainCategoryFactoryable {
		return MainCategoryViewFactory(parent: self)
	}
}

protocol AddCheckListTitleFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class AddCheckListTitleViewFactory: Factory<AddCheckListTitleDependency>, AddCheckListTitleFactoryable {
	override init(parent: AddCheckListTitleDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = AddCheckListTitleComponent(parent: parent)
		let router = AddCheckListTitleRouter(
			mainCategoryViewFactory: component.mainCategoryFactoryable
		)
		let viewModel = AddCheckListTitleViewModel(
			validCheckUseCase: component.validCheckUseCase,
			persistenceUseCase: component.persistenceUseCase
		)
		let viewController = AddCheckListTitleViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
