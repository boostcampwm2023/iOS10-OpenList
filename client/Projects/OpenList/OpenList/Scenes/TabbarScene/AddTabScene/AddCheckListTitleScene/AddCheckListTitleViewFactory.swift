//
//  AddCheckListTitleViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol AddCheckListTitleDependency: Dependency {
	var validCheckUseCase: ValidCheckUseCase { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class AddCheckListTitleComponent:
	Component<AddCheckListTitleDependency>,
	MajorCategoryDependency {
	fileprivate var validCheckUseCase: ValidCheckUseCase {
		return parent.validCheckUseCase
	}
	
	fileprivate var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
	
	fileprivate var majorCategoryFactoryable: MajorCategoryFactoryable {
		return MajorCategoryViewFactory(parent: self)
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
			majorCategoryViewFactory: component.majorCategoryFactoryable
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
