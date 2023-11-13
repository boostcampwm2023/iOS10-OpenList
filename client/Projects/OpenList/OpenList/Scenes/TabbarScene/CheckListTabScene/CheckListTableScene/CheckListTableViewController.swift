//
//  CheckListTableViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import UIKit
import Combine

protocol CheckListTableRoutingLogic: AnyObject { }

final class CheckListTableViewController: UIViewController, ViewControllable {
	// MARK: - CollectionView Type
	enum Section {
		case main
	}
	typealias CheckListTableDataSource = UICollectionViewDiffableDataSource<Section, CheckListTableItem>
	typealias CheckListTableCellRegistration = UICollectionView.CellRegistration<CheckListTableCell, CheckListTableItem>
	
	// MARK: - Properties
	private let router: CheckListTableRoutingLogic
	private let viewModel: any CheckListTableViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private var dataSource: CheckListTableDataSource?
	private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - Initializers
	init(
		router: CheckListTableRoutingLogic,
		viewModel: some CheckListTableViewModelable
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
		self.setupConfigure()
		self.setupLayout()
		self.bind()
		self.viewLoad.send()
	}
}

// MARK: - Bind Methods
extension CheckListTableViewController: ViewBindable {
	typealias State = CheckListTableState
	typealias OutputError = Error
	
	func bind() {
		let input = CheckListTableInput(viewLoad: viewLoad)
		
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, output) in owner.render(output) }
			.store(in: &cancellables)
	}
	
	func render(_ state: State) {
		switch state {
		case .error(let error):
			handleError(error)
		case .reload(let items):
			reload(items: items)
		}
	}
	
	func handleError(_ error: OutputError) { }
}

// MARK: Helper
private extension CheckListTableViewController {
	func reload(items: [CheckListTableItem]) {
		guard var snapshot = self.dataSource?.snapshot() else {
			return
		}
		snapshot.appendItems(items, toSection: .main)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: SetUp
private extension CheckListTableViewController {
	func setupConfigure() {
		dataSource = setupDataSource()
		var snapshot = NSDiffableDataSourceSnapshot<Section, CheckListTableItem>()
		snapshot.appendSections([.main])
		dataSource?.apply(snapshot)
		
		collectionView.delegate = self
	}
	
	func setupLayout() {
		view.addSubview(collectionView)
		collectionView.frame = view.bounds
		
		var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
		configuration.showsSeparators = false
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		collectionView.collectionViewLayout = layout
	}
	
	func setupDataSource() -> CheckListTableDataSource {
		let cellRegistration = CheckListTableCellRegistration { cell, indexPath, itemIdentifier in
			cell.configure(item: itemIdentifier)
		}
		
		let dataSource = CheckListTableDataSource(
			collectionView: collectionView,
			cellProvider: { collectionView, indexPath, item in
				return collectionView.dequeueConfiguredReusableCell(
					using: cellRegistration,
					for: indexPath,
					item: item
				)
			}
		)
		
		return dataSource
	}
}

extension CheckListTableViewController: UICollectionViewDelegate { }
