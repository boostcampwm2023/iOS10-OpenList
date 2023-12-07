//
//  WithDetailCheckListViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CustomNetwork
import Foundation

protocol WithDetailCheckListDependency: Dependency {
	var session: CustomSession { get }
	var withCheckListUseCase: WithCheckListUseCase { get }
}

final class WithDetailCheckListComponent: Component<WithDetailCheckListDependency> {
	var withCheckListUseCase: WithCheckListUseCase { parent.withCheckListUseCase }
	
	fileprivate var crdtUseCase: CRDTUseCase {
		return DefaultCRDTUseCase(crdtRepository: crdtRepository)
	}
	
	fileprivate var crdtRepository: CRDTRepository {
		return DefaultCRDTRepository(session: parent.session, crdtStorage: crdtStorage)
	}
	
	fileprivate var crdtStorage: CRDTStorage {
		return DefaultCRDTStorage()
	}
}

protocol WithDetailCheckListFactoryable: Factoryable {
	func make(with id: UUID) -> ViewControllable
}

final class WithDetailCheckListViewFactory: Factory<WithDetailCheckListDependency>, WithDetailCheckListFactoryable {
	override init(parent: WithDetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make(with id: UUID) -> ViewControllable {
		let component = WithDetailCheckListComponent(parent: parent)
		let router = WithDetailCheckListRouter()
		let viewModel = WithDetailCheckListViewModel(
			id: id,
			crdtUseCase: component.crdtUseCase,
			withCheckListUseCase: component.withCheckListUseCase
		)
		let viewController = WithDetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
