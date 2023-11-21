//
//  MajorCategoryViewController.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine
import UIKit

protocol MajorCategoryRoutingLogic: AnyObject {}

final class MajorCategoryViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: MajorCategoryRoutingLogic
  private let viewModel: any MajorCategoryViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
  private var cancellables: Set<AnyCancellable> = []

  // MARK: - Initializers
	init(
		router: MajorCategoryRoutingLogic,
		viewModel: some MajorCategoryViewModelable
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
		view.backgroundColor = .systemBackground
		bind()
		viewWillAppear.send()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		viewWillAppear.send()
	}
}

// MARK: - Bind Methods
extension MajorCategoryViewController: ViewBindable {
	typealias State = MajorCategoryState
	typealias OutputError = Error

	func bind() {
		let input = MajorCategoryInput(
			viewLoad: viewLoad,
			viewWillAppear: viewWillAppear
		)
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state)}
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .error(let error):
			handleError(error)
		case .load(let category):
			print(category)
		case .viewWillAppear(let title):
			navigationItem.title = title
		}
	}

	func handleError(_ error: OutputError) {
	}
}
