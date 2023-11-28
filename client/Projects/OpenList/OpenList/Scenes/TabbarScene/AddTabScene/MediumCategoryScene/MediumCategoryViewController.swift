//
//  MediumCategoryViewController.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine
import UIKit

protocol MediumCategoryRoutingLogic: AnyObject {}

final class MediumCategoryViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: MediumCategoryRoutingLogic
  private let viewModel: any MediumCategoryViewModelable
  private var cancellables: Set<AnyCancellable> = []
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let collectionViewCellDidSelect: PassthroughSubject<String, Never> = .init()
	
	// MARK: - UI Components
	private let nextButton = ConfirmButton(title: "다음")

  // MARK: - Initializers
	init(
		router: MediumCategoryRoutingLogic,
		viewModel: some MediumCategoryViewModelable
	) {
		self.router = router
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

  @available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .systemBackground
		self.bind()
	}
}

// MARK: - Bind Methods
extension MediumCategoryViewController: ViewBindable {
	typealias State = MediumCategoryState
	typealias OutputError = Error

	func bind() {
		let input = MediumCategoryInput(
			viewLoad: viewLoad,
			nextButtonDidTap: nextButton.tapPublisher,
			collectionViewCellDidSelect: collectionViewCellDidSelect
		)
		let output = viewModel.transform(input)
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .error(let error):
			handleError(error)
		case .load(let categories):
			dump(categories)
		case .routeToNext(let category):
			dump(category)
		}
	}

	func handleError(_ error: OutputError) {}
}
