//___FILEHEADER___

import Combine

protocol ___VARIABLE_productName___ViewModelable: ViewModelable 
where Input == ___VARIABLE_productName___Input,
      State == ___VARIABLE_productName___State,
      Output == AnyPublisher<State, Never> { }

final class ___VARIABLE_productName___ViewModel {

}

extension ___VARIABLE_productName___ViewModel: ___VARIABLE_productName___ViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
      // TODO: Output 퍼블러셔를 나열합니다.
    ).eraseToAnyPublisher()
  }
}

private extension ___VARIABLE_productName___ViewModel {
  // TODO: Input을 Output으로 변환하는 메서드를 작성합니다.
}