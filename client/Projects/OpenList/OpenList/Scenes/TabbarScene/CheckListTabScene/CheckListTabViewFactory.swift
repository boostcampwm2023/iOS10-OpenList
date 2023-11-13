//
//  CheckListTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol CheckListTabDependency: Dependency {
	var sampleRepository: SampleRepository { get }
}

final class CheckListTabComponent: Component<CheckListTabDependency> {
	fileprivate var sampleUseCase: SampleUseCase {
		return DefaultSampleUseCase(sampleRepository: self.parent.sampleRepository)
	}
}

protocol CheckListTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListTabViewFactory: Factory<CheckListTabDependency>, CheckListTabFactoryable {
	override init(parent: CheckListTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = CheckListTabComponent(parent: parent)
		let viewModel = CheckListTabViewModel(useCase: component.sampleUseCase)
		let router = CheckListTabRouter()
		let viewController = CheckListTabViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
