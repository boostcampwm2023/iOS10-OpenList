//
//  MinorCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine

protocol MinorCategoryViewModelable: ViewModelable 
where Input == MinorCategoryInput,
      State == MinorCategoryState,
      Output == AnyPublisher<State, Never> { }

final class MinorCategoryViewModel {

}

extension MinorCategoryViewModel: MinorCategoryViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany([
      // TODO: Output 퍼블러셔를 나열합니다.
    ]).eraseToAnyPublisher
  }
}

private extension MinorCategoryViewModel {
  // TODO: Input을 Output으로 변환하는 메서드를 작성합니다.
}