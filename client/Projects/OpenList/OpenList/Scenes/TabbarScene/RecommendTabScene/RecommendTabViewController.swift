//
//  RecommendTabViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Combine
import UIKit

protocol RecommendTabRoutingLogic: AnyObject {}

final class RecommendTabViewController: UIViewController, ViewControllable {
	// MARK: - Properties
	private let router: RecommendTabRoutingLogic
	private let viewModel: any RecommendTabModelable
	private var cancellables: Set<AnyCancellable> = []
	
	// MARK: - UI Components
	private let titleLabel: UILabel = .init()
	private let recommendCategoryTabView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var recommendCategoryDataSource: RecommendCategoryTabDiffableDataSource?
	private let recommendCheckListView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var recommendCheckListDataSource: RecommendCheckListDiffableDataSource?
	
	// MARK: - Event Subjects
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
	private let recommendCategoryDidSelect: PassthroughSubject<String, Never> = .init()
	
	// MARK: - Initializers
	init(router: RecommendTabRoutingLogic, viewModel: some RecommendTabModelable) {
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
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send()
	}
}

// MARK: - Bind Methods
extension RecommendTabViewController: ViewBindable {
	typealias State = RecommendTabState
	typealias OutputError = Error
	
	func bind() {
		let input = RecommendTabInput(
			viewWillAppear: viewWillAppear,
			fetchRecommendCheckList: recommendCategoryDidSelect
		)
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, output) in owner.render(output) }
			.store(in: &cancellables)
	}
	
	func render(_ state: State) {
		switch state {
		case .reloadRecommendCategory(let items):
			recommendCategoryDataSource?.updateCategoryItem(with: items)
			guard !items.isEmpty else { return }
			selectRecommendCategory(with: items[0].name, at: 0)
			LoadingIndicator.hideLoading()
			
		case let .reloadRecommendCheckList(checkList):
			recommendCheckListDataSource?.updateRecommendCheckList(with: checkList)
			LoadingIndicator.hideLoading()
		case .error(let error):
			guard let error else { return }
			handleError(error)
			LoadingIndicator.hideLoading()
		}
	}
	
	func handleError(_ error: OutputError) { }
}

private extension RecommendTabViewController {
	enum Constants {
		static let titleLabelTopPadding: CGFloat = 10
		static let recommendCategoryTabViewTopPadding: CGFloat = 20
		static let horizontalPadding: CGFloat = 20
		static let title = "이런 체크리스트는\n어떤가요?"
		static let reocmmendCheckListViewTopPadding: CGFloat = 30
	}
	
	func setViewAttributes() {
		view.backgroundColor = .background
		setTitleLabelAttributes()
		setRecommendCategoryTabViewAttributes()
		setRecommendCheckListViewAttributes()
	}
	
	func setTitleLabelAttributes() {
		titleLabel.text = Constants.title
		titleLabel.textColor = .label
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .extra)
		titleLabel.numberOfLines = 2
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setRecommendCategoryTabViewAttributes() {
		recommendCategoryTabView.registerCell(RecommendCategoryTabCell.self)
		recommendCategoryTabView.collectionViewLayout = makeRecommendCategoryTabLayout()
		recommendCategoryDataSource = makeRecommendCategoryDataSource()
		recommendCategoryTabView.translatesAutoresizingMaskIntoConstraints = false
		recommendCategoryTabView.isPagingEnabled = true
		recommendCategoryTabView.delegate = self
	}
	
	func setRecommendCheckListViewAttributes() {
		recommendCheckListView.registerCell(RecommendCheckListCell.self)
		recommendCheckListView.collectionViewLayout = makeRecommendCheckListLayout()
		recommendCheckListDataSource = makeRecommendCheckListDataSource()
		recommendCheckListView.translatesAutoresizingMaskIntoConstraints = false
		recommendCheckListView.showsVerticalScrollIndicator = false
		recommendCheckListView.showsHorizontalScrollIndicator = false
	}
	
	func setViewHierarchies() {
		view.addSubview(titleLabel)
		view.addSubview(recommendCategoryTabView)
		view.addSubview(recommendCheckListView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.topAnchor,
				constant: Constants.titleLabelTopPadding
			),
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
			
			recommendCategoryTabView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: Constants.recommendCategoryTabViewTopPadding
			),
			recommendCategoryTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			recommendCategoryTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			recommendCategoryTabView.heightAnchor.constraint(equalToConstant: 24),
			
			recommendCheckListView.topAnchor.constraint(
				equalTo: recommendCategoryTabView.bottomAnchor,
				constant: Constants.reocmmendCheckListViewTopPadding
			),
			recommendCheckListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			recommendCheckListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			recommendCheckListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

private extension RecommendTabViewController {
	func selectRecommendCategory(with categoryName: String, at index: Int) {
		recommendCategoryDidSelect.send(categoryName)
		
		recommendCategoryTabView.selectItem(
			at: IndexPath(row: index, section: 0),
			animated: true,
			scrollPosition: .centeredHorizontally
		)
	}
	
	func makeRecommendCategoryTabLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .estimated(100),
			heightDimension: .absolute(24)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(
			widthDimension: .estimated(100),
			heightDimension: .absolute(24)
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitems: [item]
		)
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .continuous
		section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func makeRecommendCheckListLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 40
		section.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func makeRecommendCategoryDataSource() -> RecommendCategoryTabDiffableDataSource {
		return .init(collectionView: recommendCategoryTabView) { collectionView, indexPath, item in
			let cell = collectionView.dequeueCell(RecommendCategoryTabCell.self, for: indexPath)
			cell.configure(title: item.name)
			return cell
		}
	}
	
	func makeRecommendCheckListDataSource() -> RecommendCheckListDiffableDataSource {
		typealias RecommendCheckListRegistration = UICollectionView.CellRegistration<RecommendCheckListCell, FeedCheckList>
		let cellRegistration = RecommendCheckListRegistration.init { cell, _, item in
			cell.configure(with: item)
		}
		return RecommendCheckListDiffableDataSource(
			collectionView: recommendCheckListView
		) { collectionView, indexPath, item in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}
	}
}

extension RecommendTabViewController: UICollectionViewDelegate {
	// category tab view delegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard
			let recommendCategoryDataSource,
			let item = recommendCategoryDataSource.itemIdentifier(for: indexPath)
		else { return }
		selectRecommendCategory(with: item.name, at: indexPath.row)
	}
}
