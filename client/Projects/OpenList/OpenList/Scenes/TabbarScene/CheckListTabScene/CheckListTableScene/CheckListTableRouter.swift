//
//  CheckListTableRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine
import Foundation

final class CheckListTableRouter {
	weak var viewController: ViewControllable?
	private var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	private var cancellables: Set<AnyCancellable> = []
	
	private var detailCheckListViewFactory: DetailCheckListFactoryable
	weak var detailCheckListViewControllable: ViewControllable?
	
	init(
		detailCheckListViewFactory: DetailCheckListFactoryable,
		deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	) {
		self.detailCheckListViewFactory = detailCheckListViewFactory
		self.deepLinkSubject = deepLinkSubject
		bind()
	}
	
	func bind() {
		deepLinkSubject
			.receive(on: DispatchQueue.main)
			.sink { [weak self] target in
				guard let self else { return }
				switch target {
				case let .routeToSharedCheckList(id):
					self.routeToDetailScene(with: id)
				}
			}
			.store(in: &cancellables)
	}
}

// MARK: - RoutingLogic
extension CheckListTableRouter: CheckListTableRoutingLogic {
	func routeToDetailScene(with title: String) {
		let detailCheckListViewControllable = detailCheckListViewFactory.make(with: title)
		self.detailCheckListViewControllable = detailCheckListViewControllable
		viewController?.pushViewController(detailCheckListViewControllable, animated: true)
	}
}
