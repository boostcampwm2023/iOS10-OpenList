//
//  RecommendCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

enum RecommendCheckListSection { case recommendCheckList }
typealias RecommendCheckListDataSource = UICollectionViewDiffableDataSource<RecommendCheckListSection, CheckList>
typealias RecommendCheckListSnapshot = NSDiffableDataSourceSnapshot<RecommendCheckListSection, CheckList>

final class RecommendCheckListDiffableDataSource: RecommendCheckListDataSource {
	override init(
		collectionView: UICollectionView,
		cellProvider: @escaping UICollectionViewDiffableDataSource<RecommendCheckListSection, CheckList>.CellProvider
	) {
		super.init(collectionView: collectionView, cellProvider: cellProvider)
		makeSection()
	}
	
	func updateRecommendCheckList(with items: [CheckList]) {
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
