//
//  DetailCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Foundation

protocol PrivateDetailCheckListDependency: Dependency {
	var checkListRepository: CheckListRepository { get }
	var withCheckListRepository: WithCheckListRepository { get }
	var crdtRepository: CRDTRepository { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class PrivateDetailCheckListComponent: Component<PrivateDetailCheckListDependency> {
	fileprivate var detailCheckListUseCase: DetailCheckListUseCase {
		return DefaultDetailCheckListUseCase(
			checkListRepository: parent.checkListRepository,
			withCheckListRepository: parent.withCheckListRepository,
			crdtDocumentUseCase: DefaultCRDTUseCase(crdtRepository: parent.crdtRepository)
		)
	}
}

protocol PrivateDetailCheckListFactoryable: Factoryable {
	func make(with id: UUID) -> ViewControllable
}

final class PrivateDetailCheckListViewFactory:
	Factory<PrivateDetailCheckListDependency>,
	PrivateDetailCheckListFactoryable {
	override init(parent: PrivateDetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make(with id: UUID) -> ViewControllable {
		let component = PrivateDetailCheckListComponent(parent: parent)
		let router = PrivateDetailCheckListRouter()
		let viewModel = PrivateDetailCheckListViewModel(
			id: id,
			detailCheckListUseCase: component.detailCheckListUseCase,
			persistenceUseCase: component.parent.persistenceUseCase
		)
		let viewController = PrivateDetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
