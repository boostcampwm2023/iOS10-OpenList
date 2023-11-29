//
//  MainCategoryViewController.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine
import UIKit

protocol MainCategoryRoutingLogic: AnyObject {
	func routeToTitleView()
	func routeToSubCategoryView(_ title: String, _ mainCategory: CategoryItem)
	func routeToConfirmView(_ categoryInfo: CategoryInfo)
}

final class MainCategoryViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: MainCategoryRoutingLogic
  private let viewModel: any MainCategoryViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let collectionViewCellDidSelect: PassthroughSubject<String, Never> = .init()
  private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - UI Components
	enum Section {
		case category
	}
	
	typealias CategoryDataSource = UICollectionViewDiffableDataSource<Section, String>
	typealias CategoryCellRegistration = UICollectionView.CellRegistration<CategoryCollectionViewCell, String>
	
	private let nextButton = ConfirmButton(title: "다음")
	private let skipButton: UIButton = .init()
	private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
	private var dataSource: CategoryDataSource?
	private let gradationView: CategoryProgressView = .init(stage: .main)
	private var navigationBar: OpenListNavigationBar = .init(isBackButtonHidden: false)
	
  // MARK: - Initializers
	init(
		router: MainCategoryRoutingLogic,
		viewModel: some MainCategoryViewModelable
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
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
		viewLoad.send()
	}
}

// MARK: - Bind Methods
extension MainCategoryViewController: ViewBindable {
	typealias State = MainCategoryState
	typealias OutputError = Error

	func bind() {
		let input = MainCategoryInput(
			viewLoad: viewLoad,
			nextButtonDidTap: nextButton.tapPublisher,
			skipButtonDidTap: skipButton.tapPublisher,
			collectionViewCellDidSelect: collectionViewCellDidSelect
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
		case .load(let categories):
			reload(categories: categories.map { $0.name })
		case .routeToNext(let title, let category):
			router.routeToSubCategoryView(title, category)
		case .routeToLast(let categoryInfo):
			router.routeToConfirmView(categoryInfo)
		case .none:
			break
		}
	}

	func handleError(_ error: OutputError) {
	}
}

// MARK: - Helper
private extension MainCategoryViewController {
	func reload(categories: [String]) {
		guard var snapshot = dataSource?.snapshot() else { return }
		snapshot.appendItems(categories, toSection: .category)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - UI Configure
private extension MainCategoryViewController {
	func setViewAttributes() {
		view.backgroundColor = .background
		dataSource = setDataSource()
		snapShot()
		setNavigationBar()
		setGradationView()
		setCollectionView()
		setSkipButton()
		setNextButton()
	}
	
	enum CollectionViewLayoutConstant {
		static let itemSizeWidth = 58.0
		static let itemSizeHeight = 36.0
		static let groupSizeHeight = 36.0
		static let headerHeight = 34.0
		static let groupInternalSpacing = 8.0
		static let sectionInternalSpacing = 10.0
	}
	
	func setCollectionView() {
		collectionView.backgroundColor = .background
		collectionView.register(
			CategoryHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: CategoryHeaderView.identifier)
		
		let layout: UICollectionViewCompositionalLayout = {
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .estimated(CollectionViewLayoutConstant.itemSizeWidth),
				heightDimension: .absolute(CollectionViewLayoutConstant.groupSizeHeight)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
					
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(CollectionViewLayoutConstant.groupSizeHeight)
			)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.interItemSpacing = NSCollectionLayoutSpacing.fixed(CollectionViewLayoutConstant.groupInternalSpacing)
			
			let headerSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(CollectionViewLayoutConstant.headerHeight)
			)
			
			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerSize,
				elementKind: UICollectionView.elementKindSectionHeader,
				alignment: .top
			)
			
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = CollectionViewLayoutConstant.sectionInternalSpacing
			section.boundarySupplementaryItems = [header]
			
			return UICollectionViewCompositionalLayout(section: section)
		}()
		collectionView.delegate = self
		collectionView.collectionViewLayout = layout
		collectionView.allowsMultipleSelection = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func snapShot() {
		var snapShot = NSDiffableDataSourceSnapshot<Section, String>()
		snapShot.appendSections([.category])
		dataSource?.apply(snapShot)
	}
	
	func setDataSource() -> CategoryDataSource {
		let cellRegistration = CategoryCellRegistration { cell, _, itemIdentifier in
			cell.configure(categoryItem: itemIdentifier)
		}
		
		let dataSource = CategoryDataSource(
			collectionView: collectionView,
			cellProvider: { collectionView, indexPath, item in
				return collectionView.dequeueConfiguredReusableCell(
					using: cellRegistration,
					for: indexPath,
					item: item
				)
			}
		)
		
		dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
			guard self != nil, kind == UICollectionView.elementKindSectionHeader else { return nil }
			
			guard let headerView = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: CategoryHeaderView.identifier,
				for: indexPath
			) as? CategoryHeaderView else { return nil }
			
			headerView.configure(.main)
			
			return headerView
		}
		return dataSource
	}

	func setSkipButton() {
		skipButton.configureAsSkipButton(title: "건너뛰기")
	}
	
	func setNextButton() {
		nextButton.isEnabled = false
		nextButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setGradationView() {
		gradationView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setNavigationBar() {
		navigationBar.delegate = self
		navigationBar.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(gradationView)
		view.addSubview(nextButton)
		view.addSubview(skipButton)
		view.addSubview(collectionView)
	}
	
	enum LayoutConstant {
		static let defaultPadding = 20.0
		static let navigationGradationViewSpacing = 10.0
		static let gradationCollectionViewSpacing = 60.0
		static let gradationViewHeight = 27.0
		static let nextAndSkipButtonSpacing = 10.0
		static let navigationBarHeight = 56.0
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
			navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			navigationBar.heightAnchor.constraint(equalToConstant: LayoutConstant.navigationBarHeight),
			
			gradationView.topAnchor.constraint(
				equalTo: navigationBar.bottomAnchor,
				constant: LayoutConstant.navigationGradationViewSpacing
			),
			gradationView.leadingAnchor.constraint(
				equalTo: safeArea.leadingAnchor,
				constant: LayoutConstant.defaultPadding
			),
			gradationView.trailingAnchor.constraint(
				equalTo: safeArea.trailingAnchor,
				constant: -LayoutConstant.defaultPadding
			),
			gradationView.heightAnchor.constraint(equalToConstant: LayoutConstant.gradationViewHeight),
			
			collectionView.topAnchor.constraint(
				equalTo: gradationView.bottomAnchor,
				constant: LayoutConstant.gradationCollectionViewSpacing),
			collectionView.bottomAnchor.constraint(
				equalTo: skipButton.topAnchor,
				constant: -LayoutConstant.defaultPadding),
			collectionView.leadingAnchor.constraint(
				equalTo: safeArea.leadingAnchor,
				constant: LayoutConstant.defaultPadding),
			collectionView.trailingAnchor.constraint(
				equalTo: safeArea.trailingAnchor,
				constant: -LayoutConstant.defaultPadding),
			
			nextButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
			nextButton.leadingAnchor.constraint(
				equalTo: safeArea.leadingAnchor,
				constant: LayoutConstant.defaultPadding
			),
			nextButton.trailingAnchor.constraint(
				equalTo: safeArea.trailingAnchor,
				constant: -LayoutConstant.defaultPadding
			),
			
			skipButton.bottomAnchor.constraint(
				equalTo: nextButton.topAnchor,
				constant: -LayoutConstant.nextAndSkipButtonSpacing
			),
			skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
}

extension MainCategoryViewController: UICollectionViewDelegate {
	func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		nextButton.isEnabled = true
		guard
			let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell,
			let categoryText = cell.getCatergoryName()
		else { return }
		collectionViewCellDidSelect.send(categoryText)
	}
}

extension MainCategoryViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(
		_ navigationBar: OpenListNavigationBar,
		didTapBackButton button: UIButton
	) {
		router.routeToTitleView()
	}
	
	func openListNavigationBar(
		_ navigationBar: OpenListNavigationBar,
		didTapBarItem item: OpenListNavigationBarItem
	) {
		return
	}
}
