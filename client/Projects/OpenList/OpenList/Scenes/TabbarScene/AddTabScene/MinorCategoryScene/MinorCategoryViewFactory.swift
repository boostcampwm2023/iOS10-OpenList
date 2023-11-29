//
//  MinorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol MinorCategoryDependency: Dependency {
  // TODO: 부모에게 넘겨받을 의존성 프로퍼티를 작성합니다.
}

final class MinorCategoryComponent: Component<MinorCategoryDependency> {
  // TODO: 부모에게 넘겨받은 의존성을 가지고  MinorCategory 뷰를 만드는데 필요한 의존성을 만듭니다.
  // 또한 자식 뷰에게 넘겨줄 의존성도 정의할 수 있습니다.
}

protocol MinorCategoryFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class MinorCategoryViewFactory: Factory<MinorCategoryDependency>, MinorCategoryFactoryable {
	override init(parent: MinorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = MinorCategoryRouter()
		let viewModel = MinorCategoryViewModel()
		let viewController = MinorCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
