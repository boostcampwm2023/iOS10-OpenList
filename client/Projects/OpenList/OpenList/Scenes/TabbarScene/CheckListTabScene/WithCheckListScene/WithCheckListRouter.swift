//
//  WithCheckListRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine
import Foundation

final class WithCheckListRouter {
	weak var viewController: ViewControllable?
	private var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	private var cancellables: Set<AnyCancellable> = []
	private var withCheckListDetailFactory: WithDetailCheckListFactoryable
	
	init(
		withCheckListDetailFactory: WithDetailCheckListFactoryable,
		deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	) {
		self.withCheckListDetailFactory = withCheckListDetailFactory
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
extension WithCheckListRouter: WithCheckListRoutingLogic {
	func routeToDetailScene(with cid: UUID) {
		let withCheckListDetailViewControllable = withCheckListDetailFactory.make(with: cid)
		viewController?.pushViewController(withCheckListDetailViewControllable, animated: true)
	}
}
