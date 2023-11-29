//
//  SubCategoryViewController.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine
import UIKit

protocol SubCategoryRoutingLogic: AnyObject {}

final class SubCategoryViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: SubCategoryRoutingLogic
  private let viewModel: any SubCategoryViewModelable
  private var cancellables: Set<AnyCancellable> = []
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let collectionViewCellDidSelect: PassthroughSubject<String, Never> = .init()
	
	// MARK: - UI Components
	private let nextButton = ConfirmButton(title: "다음")

  // MARK: - Initializers
	init(
		router: SubCategoryRoutingLogic,
		viewModel: some SubCategoryViewModelable
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
extension SubCategoryViewController: ViewBindable {
	typealias State = SubCategoryState
	typealias OutputError = Error

	func bind() {
		let input = SubCategoryInput(
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
