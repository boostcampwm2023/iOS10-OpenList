//
//  CheckListTableViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine
import CustomNetwork
import Foundation

protocol CheckListTableDependency: Dependency {
	var checkListRepository: CheckListRepository { get }
	var crdtRepository: CRDTRepository { get }
}

final class CheckListTableComponent:
	Component<CheckListTableDependency>,
	PrivateDetailCheckListDependency {
	var crdtRepository: CRDTRepository { return parent.crdtRepository }
	
	var checkListRepository: CheckListRepository {
		return parent.checkListRepository
	}
	
	var withCheckListRepository: WithCheckListRepository {
		return DefaultWithCheckListRepository()
	}
	
	fileprivate var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
	
	fileprivate var privateCheckListDetailFactoryable: PrivateDetailCheckListFactoryable {
		return PrivateDetailCheckListViewFactory(parent: self)
	}
}

protocol CheckListTableFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListTableViewFactory: Factory<CheckListTableDependency>, CheckListTableFactoryable {
	override init(parent: CheckListTableDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = CheckListTableComponent(parent: parent)
		let router = CheckListTableRouter(privateCheckListDetailFactory: component.privateCheckListDetailFactoryable)
		let viewModel = CheckListTableViewModel(persistenceUseCase: component.persistenceUseCase)
		let viewController = CheckListTableViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
