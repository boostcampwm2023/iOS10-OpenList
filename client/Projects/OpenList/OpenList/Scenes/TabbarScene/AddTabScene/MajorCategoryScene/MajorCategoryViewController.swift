//
//  MajorCategoryViewController.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine
import UIKit

protocol MajorCategoryRoutingLogic: AnyObject {}

final class MajorCategoryViewController: UIViewController, ViewControllable {
	// MARK: - Properties
  private let router: MajorCategoryRoutingLogic
  private let viewModel: any MajorCategoryViewModelable
	private let viewLoad: PassthroughSubject<Void, Never> = .init()
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
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
	private let gradationView: CategoryProgressView = .init(stage: .major)
	private var navigationBar: OpenListNavigationBar = .init(isBackButtonHidden: false, backButtonTitle: "뒤로")
	
  // MARK: - Initializers
	init(
		router: MajorCategoryRoutingLogic,
		viewModel: some MajorCategoryViewModelable
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send()
	}
}

// MARK: - Bind Methods
extension MajorCategoryViewController: ViewBindable {
	typealias State = MajorCategoryState
	typealias OutputError = Error

	func bind() {
		let input = MajorCategoryInput(
			viewLoad: viewLoad,
			viewWillAppear: viewWillAppear
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
			reload(categories: categories)
		case .viewWillAppear(let title):
			dump(title)
		}
	}

	func handleError(_ error: OutputError) {
	}
}

// MARK: - Helper
private extension MajorCategoryViewController {
	func reload(categories: [String]) {
		guard var snapshot = dataSource?.snapshot() else {
			return
		}
		snapshot.appendItems(categories, toSection: .category)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - UI Configure
private extension MajorCategoryViewController {
	func setViewAttributes() {
		view.backgroundColor = .systemBackground
		dataSource = setDataSource()
		snapShot()
		setGradationView()
		setCollectionView()
		setSkipButton()
		setNextButton()
	}
	
	func setCollectionView() {
		collectionView.register(
			CategoryHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: CategoryHeaderView.identifier)
		
		let layout: UICollectionViewCompositionalLayout = {
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .estimated(58),
				heightDimension: .absolute(36)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
					
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(36)
			)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
			
			let headerSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(34)
			)
			
			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerSize,
				elementKind: UICollectionView.elementKindSectionHeader,
				alignment: .top
			)
			
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 10
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
			
			headerView.configure(.major)
			
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
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(gradationView)
		view.addSubview(nextButton)
		view.addSubview(skipButton)
		view.addSubview(collectionView)
	}
	
	func setViewConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			gradationView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			gradationView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
			gradationView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
			gradationView.heightAnchor.constraint(equalToConstant: 100),
			
			nextButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
			nextButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
			nextButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
			nextButton.heightAnchor.constraint(equalToConstant: 56),
			
			skipButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),
			skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			collectionView.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -20),
			collectionView.topAnchor.constraint(equalTo: gradationView.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
			collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
		])
	}
}

extension MajorCategoryViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		nextButton.isEnabled = true
	}
}
