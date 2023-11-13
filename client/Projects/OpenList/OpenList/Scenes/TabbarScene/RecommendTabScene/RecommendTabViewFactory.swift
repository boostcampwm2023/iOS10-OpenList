//
//  RecommendTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol RecommendTabDependency: Dependency {}

final class RecommendTabComponent: Component<RecommendTabDependency> {}

protocol RecommendTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class RecommendTabViewFactory: Factory<RecommendTabDependency>, RecommendTabFactoryable {
	override init(parent: RecommendTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = RecommendTabRouter()
		let viewController = RecommendTabViewController(router: router)
		return viewController
	}
}
