//
//  CheckListTableViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine
import Foundation

protocol CheckListTableDependency: Dependency {
	var persistenceUseCase: PersistenceUseCase { get }
	var checkListRepository: CheckListRepository { get }
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class CheckListTableComponent:
	Component<CheckListTableDependency>,
	PrivateDetailCheckListDependency {
	var checkListRepository: CheckListRepository {
		return parent.checkListRepository
	}
	
	fileprivate var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
	
	fileprivate var detailCheckListFactoryable: PrivateDetailCheckListFactoryable {
		return PrivateDetailCheckListViewFactory(parent: self)
	}
	
	fileprivate var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> {
		return parent.deepLinkSubject
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
		let router = CheckListTableRouter(
			detailCheckListViewFactory: component.detailCheckListFactoryable,
			deepLinkSubject: component.deepLinkSubject
		)
		let viewModel = CheckListTableViewModel(persistenceUseCase: component.persistenceUseCase)
		let viewController = CheckListTableViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
