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

final class CheckListTabViewFactory: CheckListTabFactoryable {
	private let component: CheckListTabComponent
	
	init(component: CheckListTabComponent){
		self.component = component
	}
	
	func make() -> ViewControllable {
		let viewModel = CheckListTabViewModel(useCase: component.sampleUseCase)
		let router = CheckListTabRouter()
		let viewController = CheckListTabViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
