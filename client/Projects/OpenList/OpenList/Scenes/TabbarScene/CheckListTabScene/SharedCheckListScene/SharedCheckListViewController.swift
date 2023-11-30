//
//  SharedCheckListViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine
import UIKit

protocol SharedCheckListRoutingLogic: AnyObject {}

final class SharedCheckListViewController: UIViewController, ViewControllable {
	private enum Section {
		case share
	}
	
	private typealias SharedCheckListViewDataSource = UICollectionViewDiffableDataSource<Section, SharedCheckListItem>
	private typealias ShareCheckListCellRegistration = UICollectionView
		.CellRegistration<SharedCheckListCell, SharedCheckListItem>
	
	// MARK: - Properties
	private let router: SharedCheckListRoutingLogic
	private let viewModel: any ViewModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - UI Components
	private let sharedCheckListView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var sharedCheckListViewDataSource: SharedCheckListViewDataSource?
	private let checkListEmptyView: CheckListEmptyView = .init(checkListType: .sharedTab)
	
	// MARK: - Initializers
	init(
		router: SharedCheckListRoutingLogic,
		viewModel: some ViewModelable
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
		view.backgroundColor = .background
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
	}
}

// MARK: - Bind Methods
extension SharedCheckListViewController: ViewBindable {
	typealias State = SharedCheckListState
	typealias OutputError = Error
	
	func bind() {}
	
	func render(_ state: State) {}
	
	func handleError(_ error: OutputError) {}
}

// MARK: - View Methods
private extension SharedCheckListViewController {
	enum LayoutConstant {
		static let bottomPadding: CGFloat = 12
	}
	
	func setViewAttributes() {
		checkListEmptyView.translatesAutoresizingMaskIntoConstraints = false
		sharedCheckListView.translatesAutoresizingMaskIntoConstraints = false
		sharedCheckListViewDataSource = makeDataSource()
		var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
		configuration.showsSeparators = false
		let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
			let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
			let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
			section.interGroupSpacing = 24
			section.contentInsets = .init(top: 0, leading: 20, bottom: 12, trailing: 20)
			return section
		}
		sharedCheckListView.collectionViewLayout = layout
		makeInitialSection()
	}
	
	func setViewHierarchies() {
		view.addSubview(sharedCheckListView)
		view.addSubview(checkListEmptyView)
	}
	
	func setViewConstraints() {
		checkListEmptyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		checkListEmptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		checkListEmptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		checkListEmptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		sharedCheckListView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		sharedCheckListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		sharedCheckListView.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor,
			constant: -LayoutConstant.bottomPadding
		).isActive = true
		sharedCheckListView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
}

private extension SharedCheckListViewController {
	func makeInitialSection() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, SharedCheckListItem>()
		snapshot.appendSections([.share])
		guard let sharedCheckListViewDataSource else { return }
		sharedCheckListViewDataSource.apply(snapshot)
	}
	
	private func makeDataSource() -> SharedCheckListViewDataSource {
		let cellRegistration = ShareCheckListCellRegistration { cell, _, item in
			cell.configure(with: item)
		}
		
		return SharedCheckListViewDataSource(
			collectionView: sharedCheckListView,
			cellProvider: { collectionView, indexPath, item in
				return collectionView.dequeueConfiguredReusableCell(
					using: cellRegistration,
					for: indexPath,
					item: item
				)
			}
		)
	}
}
