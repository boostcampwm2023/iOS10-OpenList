//
//  WithDetailCheckListViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

protocol WithDetailCheckListDependency: Dependency {}

final class WithDetailCheckListComponent: Component<WithDetailCheckListDependency> {
	fileprivate var crdtUseCase: CRDTUseCase {
		return DefaultCRDTUseCase(crdtRepository: crdtRepository)
	}
	
	fileprivate var crdtRepository: CRDTRepository {
		return DefaultCRDTRepository(crdtStorage: crdtStorage)
	}
	
	fileprivate var crdtStorage: CRDTStorage {
		return DefaultCRDTStorage()
	}
}

protocol WithDetailCheckListFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class WithDetailCheckListViewFactory: Factory<WithDetailCheckListDependency>, WithDetailCheckListFactoryable {
	override init(parent: WithDetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let component = WithDetailCheckListComponent(parent: parent)
		let router = WithDetailCheckListRouter()
		let viewModel = WithDetailCheckListViewModel(
			title: title,
			crdtUseCase: component.crdtUseCase
		)
		let viewController = WithDetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
