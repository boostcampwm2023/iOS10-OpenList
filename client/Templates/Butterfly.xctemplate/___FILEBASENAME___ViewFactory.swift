//___FILEHEADER___

import Foundation

protocol ___VARIABLE_productName___Dependency: Dependency {
  // TODO: 부모에게 넘겨받을 의존성 프로퍼티를 작성합니다.
}

final class ___VARIABLE_productName___Component: Component<___VARIABLE_productName___Dependency> {
  // TODO: 부모에게 넘겨받은 의존성을 가지고  ___VARIABLE_productName___ 뷰를 만드는데 필요한 의존성을 만듭니다.
  // 또한 자식 뷰에게 넘겨줄 의존성도 정의할 수 있습니다.
}

protocol ___VARIABLE_productName___Factoryable: Factoryable {
	func make() -> ViewControllable
}

final class ___VARIABLE_productName___ViewFactory: Factory<___VARIABLE_productName___Dependency>, ___VARIABLE_productName___Factoryable {
	override init(parent: ___VARIABLE_productName___Dependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = ___VARIABLE_productName___Router()
		let viewModel = ___VARIABLE_productName___ViewModel()
		let viewController = ___VARIABLE_productName___ViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
