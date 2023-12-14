//
//  RecommendCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

enum RecommendCheckListSection { case recommendCheckList }
typealias RecommendCheckListDataSource = UICollectionViewDiffableDataSource<RecommendCheckListSection, FeedCheckList>
typealias RecommendCheckListSnapshot = NSDiffableDataSourceSnapshot<RecommendCheckListSection, FeedCheckList>

final class RecommendCheckListDiffableDataSource: RecommendCheckListDataSource {
	override init(
		collectionView: UICollectionView,
		cellProvider: @escaping UICollectionViewDiffableDataSource<RecommendCheckListSection, FeedCheckList>.CellProvider
	) {
		super.init(collectionView: collectionView, cellProvider: cellProvider)
		makeSection()
	}
	
	func updateRecommendCheckList(with items: [FeedCheckList]) {
		var snapshot = snapshot()
		let previousItems = snapshot.itemIdentifiers
		snapshot.deleteItems(previousItems)
		snapshot.appendItems(items, toSection: .recommendCheckList)
		apply(snapshot, animatingDifferences: false)
	}
}

private extension RecommendCheckListDiffableDataSource {
	func makeSection() {
		var snapshot = RecommendCheckListSnapshot()
		snapshot.appendSections([.recommendCheckList])
		apply(snapshot, animatingDifferences: false)
	}
}
