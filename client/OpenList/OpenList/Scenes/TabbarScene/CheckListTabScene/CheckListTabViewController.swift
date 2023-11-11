//
//  CheckListTabViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

protocol CheckListTabRoutingLogic {}

final class CheckListTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
	private let router: CheckListTabRoutingLogic
	private let viewModel: CheckListTabViewModel
	
	// MARK: - Initializers
	init(router: CheckListTabRoutingLogic, viewModel: CheckListTabViewModel) {
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
		self.title = "체크리스트"
	}
}
