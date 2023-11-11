//
//  RecommendTabViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

protocol RecommendTabRoutingLogic: AnyObject {}

final class RecommendTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
	private let router: RecommendTabRoutingLogic
	
	// MARK: - Initializers
	init(router: RecommendTabRoutingLogic) {
		self.router = router
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
		self.title = "추천 피드"
	}
}
