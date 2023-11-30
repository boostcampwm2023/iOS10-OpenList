//
//  WithCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine
import Foundation

protocol WithCheckListDependency: Dependency {
	var checkListRepository: CheckListRepository { get }
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class WithCheckListComponent: Component<WithCheckListDependency>, WithDetailCheckListDependency {
	fileprivate var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> {
		return parent.deepLinkSubject
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
		let viewModel = WithCheckListViewModel()
		let viewController = WithCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
