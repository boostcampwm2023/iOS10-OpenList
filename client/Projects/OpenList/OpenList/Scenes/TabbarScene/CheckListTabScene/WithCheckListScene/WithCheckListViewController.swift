//
//  WithCheckListViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine
import UIKit

protocol WithCheckListRoutingLogic: AnyObject {
	func routeToDetailScene(with id: UUID)
}

final class WithCheckListViewController: UIViewController, ViewControllable {
	typealias CheckListTableDataSource = UICollectionViewDiffableDataSource<CheckListTabType, WithCheckList>
	typealias CheckListTableCellRegistration = UICollectionView.CellRegistration<WithCheckListCell, WithCheckList>
	
	// MARK: - Properties
	private let router: WithCheckListRoutingLogic
	private let viewModel: any WithCheckListViewModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// UI Components
	private var dataSource: CheckListTableDataSource?
	private let checkListView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private let checkListEmptyView: CheckListEmptyView = .init(checkListType: .withCheckListView)
	
	// Event Properties
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
	private let removeCheckList: PassthroughSubject<DeleteCheckListItem, Never> = .init()
	
	// MARK: - Initializers
	init(
		router: WithCheckListRoutingLogic,
		viewModel: some WithCheckListViewModelable
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
		setLongGestureRecognizerOnCollection()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send()
	}
}

// MARK: - Bind Methods
extension WithCheckListViewController: ViewBindable {
	typealias State = WithCheckListState
	typealias OutputError = Error
	
	func bind() {
		let input = WithCheckListInput(
			viewWillAppear: viewWillAppear,
			removeCheckList: removeCheckList
		)
		let state = viewModel.transform(input)
		state
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, state) in owner.render(state) }
			.store(in: &cancellables)
	}
	
	func render(_ state: State) {
		switch state {
		case .error(let error):
			handleError(error)
		case .reload(let items):
			reload(items: items)
		case .deleteItem(let item):
			deleteItem(item: item)
		}
	}
	
	func handleError(_ error: OutputError) {}
}

// MARK: Helper
private extension WithCheckListViewController {
	func reload(items: [WithCheckList]) {
		checkListEmptyView.isHidden = !items.isEmpty
		guard var snapshot = dataSource?.snapshot() else { return }
		let previousProducts = snapshot.itemIdentifiers(inSection: .withTab)
		snapshot.deleteItems(previousProducts)
		snapshot.appendItems(items, toSection: .withTab)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
	
	func deleteItem(item: DeleteCheckListItem) {
		guard
			var snapshot = dataSource?.snapshot(),
			let item = dataSource?.itemIdentifier(for: item.indexPath)
		else { return }
		let previousProducts = snapshot.itemIdentifiers(inSection: .withTab)
		snapshot.deleteItems([item])
		dataSource?.apply(snapshot, animatingDifferences: true)
		checkListEmptyView.isHidden = !(previousProducts.count == 1)
	}
}

// MARK: - View Methods
private extension WithCheckListViewController {
	enum LayoutConstant {
		static let bottomPadding: CGFloat = 12
	}
	
	func setViewAttributes() {
		checkListEmptyView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.delegate = self
		
		var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
		configuration.showsSeparators = false
		configuration.backgroundColor = .background
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)
		checkListView.collectionViewLayout = layout
		dataSource = makeDataSource()
		makeInitialSection()
	}
	
	func setViewHierarchies() {
		view.addSubview(checkListView)
		view.addSubview(checkListEmptyView)
	}
	
	func setViewConstraints() {
		checkListEmptyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		checkListEmptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		checkListEmptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		checkListEmptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		checkListView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		checkListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		checkListView.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor,
			constant: -LayoutConstant.bottomPadding
		).isActive = true
		checkListView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	func makeInitialSection() {
		var snapshot = NSDiffableDataSourceSnapshot<CheckListTabType, WithCheckList>()
		snapshot.appendSections([.withTab])
		dataSource?.apply(snapshot)
	}
	
	func makeDataSource() -> CheckListTableDataSource {
		let cellRegistration = CheckListTableCellRegistration { cell, _, itemIdentifier in
			cell.configure(with: itemIdentifier)
		}
		
		let dataSource = CheckListTableDataSource(
			collectionView: checkListView,
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

extension WithCheckListViewController: UIGestureRecognizerDelegate {
	func setLongGestureRecognizerOnCollection() {
		let longPressedGesture = UILongPressGestureRecognizer(
			target: self,
			action: #selector(handleLongPress(gestureRecognizer:))
		)
		longPressedGesture.minimumPressDuration = 0.5
		longPressedGesture.delegate = self
		longPressedGesture.delaysTouchesBegan = true
		checkListView.addGestureRecognizer(longPressedGesture)
	}
	
	@objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
		guard gestureRecognizer.state == .began else { return }
		let point = gestureRecognizer.location(in: checkListView)
		
		if let indexPath = checkListView.indexPathForItem(at: point),
			let checkList = dataSource?.itemIdentifier(for: indexPath) {
			showActionSheet(with: .init(id: checkList.sharedCheckListId, indexPath: indexPath))
			debugPrint("Long press at item: \(indexPath.row)")
		}
	}
	
	func showActionSheet(with deleteItem: DeleteCheckListItem) {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
			self?.removeCheckList.send(deleteItem)
		}
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		present(actionSheet, animated: true, completion: nil)
	}
}

extension WithCheckListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
		router.routeToDetailScene(with: item.sharedCheckListId)
	}
}
