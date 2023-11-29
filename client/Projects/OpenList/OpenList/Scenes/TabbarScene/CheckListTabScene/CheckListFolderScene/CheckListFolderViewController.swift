//
//  CheckListFolderViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine
import UIKit

protocol CheckListFolderRoutingLogic: AnyObject { }

final class CheckListFolderViewController: UIViewController, ViewControllable {
	private enum Section {
		case folder
	}
	// MARK: - Properties
	private let router: CheckListFolderRoutingLogic
	private let viewModel: any ViewModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - UI Components
	private let folderView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var folderViewDataSource: UICollectionViewDiffableDataSource<Section, CheckListFolderItem>?
	private let checkListEmptyView: CheckListEmptyView = .init(checkListType: .privateTab)
	
	// MARK: - Initializers
	init(
		router: CheckListFolderRoutingLogic,
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
		bind()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
}

// MARK: - Bind Methods
extension CheckListFolderViewController: ViewBindable {
	typealias State = CheckListFolderState
	typealias OutputError = Error
	
	func bind() {}
	
	func render(_ state: State) { }
	
	func handleError(_ error: OutputError) { }
}

// MARK: - View Methods
private extension CheckListFolderViewController {
	enum LayoutConstant {
		static let bottomPadding: CGFloat = 12
	}
	
	func setViewAttributes() {
		checkListEmptyView.translatesAutoresizingMaskIntoConstraints = false
		folderView.translatesAutoresizingMaskIntoConstraints = false
		folderView.registerCell(CheckListFolderCell.self)
		folderView.collectionViewLayout = makeFolderViewLayout()
		folderViewDataSource = .init(
			collectionView: folderView,
			cellProvider: { collectionView, indexPath, item in
				let cell = collectionView.dequeueCell(CheckListFolderCell.self, for: indexPath)
				cell.configure(with: item)
				return cell
			}
		)
		makeInitialSection()
	}
	
	func setViewHierarchies() {
		view.addSubview(folderView)
		view.addSubview(checkListEmptyView)
	}
	
	func setViewConstraints() {
		checkListEmptyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		checkListEmptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		checkListEmptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		checkListEmptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		folderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		folderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		folderView.bottomAnchor.constraint(
			equalTo: view.safeAreaLayoutGuide.bottomAnchor,
			constant: -LayoutConstant.bottomPadding
		).isActive = true
		folderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
}

private extension CheckListFolderViewController {
	func makeInitialSection() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, CheckListFolderItem>()
		snapshot.appendSections([.folder])
		guard let folderViewDataSource else { return }
		folderViewDataSource.apply(snapshot)
	}
	
	func makeFolderViewLayout() -> UICollectionViewLayout {
		let itemWidth = (UIScreen.main.bounds.width - 50) * 0.5
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .estimated(300))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		group.interItemSpacing = .fixed(10)
		
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
		section.interGroupSpacing = 20
		
		return UICollectionViewCompositionalLayout(section: section)
	}
}
