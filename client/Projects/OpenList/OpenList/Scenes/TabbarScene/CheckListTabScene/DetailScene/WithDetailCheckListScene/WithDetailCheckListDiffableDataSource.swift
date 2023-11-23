//
//  WithDetailCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import UIKit

struct WithCheckListPlaceholderItem: Hashable {}

typealias WithCheckListDataSource = UITableViewDiffableDataSource<
	WithDetailCheckListDiffableDataSource.Section,
	AnyHashable
>
typealias WithCheckListSnapshot = NSDiffableDataSourceSnapshot<
	WithDetailCheckListDiffableDataSource.Section,
	AnyHashable
>

final class WithDetailCheckListDiffableDataSource: WithCheckListDataSource {
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

extension WithDetailCheckListDiffableDataSource {
	func appendCheckListItem(_ checkListItem: CheckListItem) {
		var snapshot = snapshot()
		snapshot.appendItems([checkListItem], toSection: .checkList)
		apply(snapshot, animatingDifferences: false)
	}
	
	func updateCheckList(_ checkList: [CheckListItem]) {
		updateSection(with: checkList, to: .checkList)
	}
	
	func updateCheckListItemString(at indexPath: IndexPath, with text: String) {
		var snapshot = snapshot()
		guard var items = snapshot.itemIdentifiers(inSection: .checkList) as? [CheckListItem] else { return }
		snapshot.deleteItems(items)
		items[indexPath.row].title = text
		snapshot.appendItems(items, toSection: .checkList)
		apply(snapshot, animatingDifferences: false)
	}
	
	func deleteCheckListItem(at indexPath: IndexPath) {
		var snapshot = snapshot()
		guard let item = itemIdentifier(for: indexPath) else { return }
		snapshot.deleteItems([item])
		apply(snapshot, animatingDifferences: true)
	}
	
	func updatePlaceholder() {
		updateSection(with: [WithCheckListPlaceholderItem()], to: .placeholder)
	}
}

private extension WithDetailCheckListDiffableDataSource {
	func makeSections() {
		var snapshot = WithCheckListSnapshot()
		snapshot.appendSections([.checkList, .placeholder])
		snapshot.appendItems([WithCheckListPlaceholderItem()], toSection: .placeholder)
		apply(snapshot, animatingDifferences: false)
	}
	
	func updateSection(with items: [AnyHashable], to section: Section) {
		var snapshot = snapshot()
		let previousProducts = snapshot.itemIdentifiers(inSection: section)
		snapshot.deleteItems(previousProducts)
		snapshot.appendItems(items, toSection: section)
		apply(snapshot, animatingDifferences: false)
	}
}
