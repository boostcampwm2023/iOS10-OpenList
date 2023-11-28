//
//  CheckListTableViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine
import UIKit

protocol CheckListTableRoutingLogic: AnyObject {
	func routeToDetailScene(with id: UUID)
}

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
	private let viewAppear: PassthroughSubject<Void, Never> = .init()
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
		self.bind()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setLongGestureRecognizerOnCollection()
		setViewAttributes()
		setViewHierarchies()
		setConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewAppear.send()
	}
}

// MARK: - Bind Methods
extension CheckListTableViewController: ViewBindable {
	typealias State = CheckListTableState
	typealias OutputError = Error
	
	func bind() {
		let input = CheckListTableInput(viewAppear: viewAppear)
		
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
		snapshot.deleteItems(items)
		snapshot.appendItems(items, toSection: .main)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: SetUp
private extension CheckListTableViewController {
	func setViewAttributes() {
		dataSource = setupDataSource()
		var snapshot = NSDiffableDataSourceSnapshot<Section, CheckListTableItem>()
		snapshot.appendSections([.main])
		dataSource?.apply(snapshot)
		
		collectionView.delegate = self
	}
	
	func setViewHierarchies() {
		view.addSubview(collectionView)
		collectionView.delegate = self
	}
	
	func setConstraints() {
		collectionView.frame = view.bounds
		var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
		configuration.showsSeparators = false
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		collectionView.collectionViewLayout = layout
	}
	
	func setupDataSource() -> CheckListTableDataSource {
		let cellRegistration = CheckListTableCellRegistration { cell, _, itemIdentifier in
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
	
	func setLongGestureRecognizerOnCollection() {
		let longPressedGesture = UILongPressGestureRecognizer(
			target: self,
			action: #selector(handleLongPress(gestureRecognizer:))
		)
		longPressedGesture.minimumPressDuration = 0.5
		longPressedGesture.delegate = self
		longPressedGesture.delaysTouchesBegan = true
		collectionView.addGestureRecognizer(longPressedGesture)
	}
}

extension CheckListTableViewController: UIGestureRecognizerDelegate {
	@objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
		if gestureRecognizer.state != .began {
			return
		}
		
		let point = gestureRecognizer.location(in: collectionView)
		
		if let indexPath = collectionView.indexPathForItem(at: point) {
			showActionSheet()
			print("Long press at item: \(indexPath.row)")
		}
	}
	
	func showActionSheet() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let moveFolderAction = UIAlertAction(title: "폴더 이동", style: .default) { _ in
			print("didPress move folder")
		}
		
		let shareAction = UIAlertAction(title: "게시", style: .default) { _ in
			print("didPress share")
		}
		
		let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
			print("didPress delete")
		}
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
			print("didPress cancel")
		}
		
		actionSheet.addAction(moveFolderAction)
		actionSheet.addAction(shareAction)
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		self.present(actionSheet, animated: true, completion: nil)
	}
}

extension CheckListTableViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
		router.routeToDetailScene(with: item.id)
	}
}
