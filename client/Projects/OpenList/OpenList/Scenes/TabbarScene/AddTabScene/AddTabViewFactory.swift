//
//  AddTabViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol AddTabDependency: Dependency {
	var validCheckUseCase: ValidCheckUseCase { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class AddTabComponent: Component<AddTabDependency> {
	fileprivate var validCheckUseCase: ValidCheckUseCase {
		return parent.validCheckUseCase
	}
	
	fileprivate var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
}

protocol AddTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class AddTabViewFactory: Factory<AddTabDependency>, AddTabFactoryable {
	override init(parent: AddTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = AddTabComponent(parent: parent)
		let router = AddTabRouter()
		let viewModel = AddTabViewModel(
			validCheckUseCase: component.validCheckUseCase,
			persistenceUseCase: component.persistenceUseCase
		)
		let viewController = AddTabViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
