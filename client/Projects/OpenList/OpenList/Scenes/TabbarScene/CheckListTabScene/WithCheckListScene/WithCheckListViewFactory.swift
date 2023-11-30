//
//  WithCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine
import CustomNetwork
import Foundation

protocol WithCheckListDependency: Dependency {
	var checkListRepository: CheckListRepository { get }
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
	var session: CustomSession { get }
}

final class WithCheckListComponent: Component<WithCheckListDependency>, WithDetailCheckListDependency {
	var session: CustomSession {
		parent.session
	}
	
	fileprivate var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> {
		return parent.deepLinkSubject
	}
	
	fileprivate var withCheckListRepository: WithCheckListRepository {
		return DefaultWithCheckListRepository(session: session)
	}
	
	fileprivate var withCheckListUseCase: WithCheckListUseCase {
		return DefaultWithCheckListUseCase(withCheckListRepository: withCheckListRepository)
	}
	
	fileprivate var withCheckListDetailFactoryable: WithDetailCheckListFactoryable {
		return WithDetailCheckListViewFactory(parent: self)
	}
}

protocol WithCheckListFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class WithCheckListViewFactory: Factory<WithCheckListDependency>, WithCheckListFactoryable {
	override init(parent: WithCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = WithCheckListComponent(parent: parent)
		let router = WithCheckListRouter(
			withCheckListDetailFactory: component.withCheckListDetailFactoryable,
			deepLinkSubject: component.deepLinkSubject
		)
		let viewModel = WithCheckListViewModel(withCheckListUseCase: component.withCheckListUseCase)
		let viewController = WithCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
