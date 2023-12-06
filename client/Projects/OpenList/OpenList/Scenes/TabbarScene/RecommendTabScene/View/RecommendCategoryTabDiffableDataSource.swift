//
//  RecommendCategoryTabDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

enum RecommendCategoryTabSection { case recommendCategoryTab }
typealias RecommendCategoryTabDataSource = UICollectionViewDiffableDataSource<
	RecommendCategoryTabSection,
	CategoryItem>
typealias RecommendCategoryTabSnapshot = NSDiffableDataSourceSnapshot<
	RecommendCategoryTabSection,
	CategoryItem>

final class RecommendCategoryTabDiffableDataSource: RecommendCategoryTabDataSource {
	override init(
		collectionView: UICollectionView,
		cellProvider: @escaping UICollectionViewDiffableDataSource<RecommendCategoryTabSection, CategoryItem>.CellProvider
	) {
		super.init(collectionView: collectionView, cellProvider: cellProvider)
		makeSection()
	}
	
	func updateCategoryItem(with items: [CategoryItem]) {
		var snapshot = snapshot()
		let previousItems = snapshot.itemIdentifiers
		snapshot.deleteItems(previousItems)
		snapshot.appendItems(items, toSection: .recommendCategoryTab)
		self.apply(snapshot, animatingDifferences: false)
	}
}

private extension RecommendCategoryTabDiffableDataSource {
	func makeSection() {
		var snapshot = RecommendCategoryTabSnapshot()
		snapshot.appendSections([.recommendCategoryTab])
		apply(snapshot, animatingDifferences: false)
	}
}
