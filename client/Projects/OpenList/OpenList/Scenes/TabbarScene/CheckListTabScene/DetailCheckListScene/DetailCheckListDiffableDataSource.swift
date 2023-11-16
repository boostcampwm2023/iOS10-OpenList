//
//  DetailCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

// 도메인 모델이 나오면 변경 예정
struct CheckListItem: Hashable {
	let title: String
	var isChecked: Bool
}

struct CheckListPlaceholderItem: Hashable {}

typealias CheckListDataSource = UITableViewDiffableDataSource<DetailCheckListDiffableDataSource.Section, AnyHashable>
typealias CheckListSnapshot = NSDiffableDataSourceSnapshot<DetailCheckListDiffableDataSource.Section, AnyHashable>

final class DetailCheckListDiffableDataSource: CheckListDataSource {
	enum Section: CaseIterable {
		case checkList
		case placeholder
	}
	
	override init(
		tableView: UITableView,
		cellProvider: @escaping UITableViewDiffableDataSource<Section, AnyHashable>.CellProvider
	) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		makeSections()
	}
}

extension DetailCheckListDiffableDataSource {
	func appendItems(_ items: [AnyHashable], to section: Section) {
		var snapshot = snapshot()
		snapshot.appendItems(items, toSection: section)
		apply(snapshot, animatingDifferences: false)
	}
	
	func updateCheckListItem(with checkList: [CheckListItem]) {
		updateSection(with: checkList, to: .checkList)
	}
	
	func updatePlaceholder() {
		updateSection(with: [CheckListPlaceholderItem()], to: .placeholder)
	}
}

private extension DetailCheckListDiffableDataSource {
	func makeSections() {
		var snapshot = CheckListSnapshot()
		snapshot.appendSections([.checkList, .placeholder])
		snapshot.appendItems([CheckListPlaceholderItem()], toSection: .placeholder)
		apply(snapshot, animatingDifferences: true)
	}
	
	func updateSection(with items: [AnyHashable], to section: Section) {
		var snapshot = snapshot()
		let previousProducts = snapshot.itemIdentifiers(inSection: section)
		snapshot.deleteItems(previousProducts)
		snapshot.appendItems(items, toSection: .checkList)
		apply(snapshot, animatingDifferences: false)
	}
}
