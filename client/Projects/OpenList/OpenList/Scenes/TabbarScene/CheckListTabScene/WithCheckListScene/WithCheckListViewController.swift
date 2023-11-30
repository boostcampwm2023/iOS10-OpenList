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
	private let checkListEmptyView: CheckListEmptyView = .init(checkListType: .withTab)
	
	// Event Properties
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
	
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
		self.view.backgroundColor = .systemBackground
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
		let input = WithCheckListInput(viewWillAppear: viewWillAppear)
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
		let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
			let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
			let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
			section.interGroupSpacing = 24
			section.contentInsets = .init(top: 0, leading: 20, bottom: 12, trailing: 20)
			return section
		}
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
		
		if let indexPath = checkListView.indexPathForItem(at: point) {
			showActionSheet()
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
		
		present(actionSheet, animated: true, completion: nil)
	}
}

extension WithCheckListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
		router.routeToDetailScene(with: item.sharedCheckListId)
	}
}