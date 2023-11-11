//
//  AddTabViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import UIKit

protocol AddTabRoutingLogic {}

final class AddTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
	private let router: AddTabRoutingLogic
	
	// MARK: - Initializers
	init(router: AddTabRoutingLogic) {
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
		self.title = "체크리스트 생성"
	}
}