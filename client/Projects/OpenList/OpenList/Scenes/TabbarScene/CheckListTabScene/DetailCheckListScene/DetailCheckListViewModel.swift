//
//  DetailCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

protocol DetailCheckListViewModelable: ViewModelable
where Input == DetailCheckListInput,
  State == DetailCheckListState,
  Output == AnyPublisher<State, Never> { }

final class DetailCheckListViewModel {}

extension DetailCheckListViewModel: DetailCheckListViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>().eraseToAnyPublisher()
  }
}

private extension DetailCheckListViewModel {}
