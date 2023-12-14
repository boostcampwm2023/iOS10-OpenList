//
//  AddCheckListItemDiffableDataSource.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import UIKit

struct AddCheckListItemPlaceholderItem: Hashable {}

typealias AddCheckListItemDataSource = UITableViewDiffableDataSource<
	AddCheckListItemDiffableDataSource.Section,
	AnyHashable
>
typealias AddCheckListItemSnapshot = NSDiffableDataSourceSnapshot<
	AddCheckListItemDiffableDataSource.Section,
	AnyHashable
>

final class AddCheckListItemDiffableDataSource: AddCheckListItemDataSource {
	enum Section: CaseIterable {
		case selectItem
		case placeHolder
		case aiItem
	}
	
	override init(
		tableView: UITableView,
		cellProvider: @escaping UITableViewDiffableDataSource<Section, AnyHashable>.CellProvider
	) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		makeSections()
	}
}

extension AddCheckListItemDiffableDataSource {
	func updateSelectItem(_ checkList: [CheckListItem]) {
		updateSection(with: checkList, to: .selectItem)
	}
	
	func updateAiItem(_ checkList: [CheckListItem]) {
		updateSection(with: checkList, to: .aiItem)
	}

	func appendCheckListItem(_ checkListItem: CheckListItem) {
		var snapshot = snapshot()
		snapshot.appendItems([checkListItem], toSection: .selectItem)
		apply(snapshot, animatingDifferences: true)
	}
	
	func deleteCheckListItem(at indexPath: IndexPath) {
		var snapshot = snapshot()
		guard let item = itemIdentifier(for: indexPath) else { return }
		snapshot.deleteItems([item])
		apply(snapshot, animatingDifferences: true)
	}
	
	func deleteCheckListItem(with id: UUID, section: Section) {
		var snapshot = snapshot()
		guard
			var items = snapshot.itemIdentifiers(inSection: section) as? [CheckListItem],
			let removeIndex = items.firstIndex(where: {$0.id == id})
		else { return }
		snapshot.deleteItems(items)
		items.remove(at: removeIndex)
		snapshot.appendItems(items, toSection: section)
		apply(snapshot, animatingDifferences: false)
	}
	
	func getCheckListItem(section: Section) -> [CheckListItem] {
		let snapshot = snapshot()
		guard let items = snapshot.itemIdentifiers(inSection: section) as? [CheckListItem] else { return [] }
		return items
	}
	
	func deleteItems(_ items: [CheckListItem]) {
		var snapshot = snapshot()
		snapshot.deleteItems(items)
		apply(snapshot, animatingDifferences: false)
	}
}

private extension AddCheckListItemDiffableDataSource {
	func makeSections() {
		var snapshot = AddCheckListItemSnapshot()
		snapshot.appendSections([.selectItem, .placeHolder, .aiItem])
		snapshot.appendItems([AddCheckListItemPlaceholderItem()], toSection: .placeHolder)
		apply(snapshot, animatingDifferences: false)
	}
	
	func updateSection(with items: [AnyHashable], to section: Section) {
		var snapshot = snapshot()
		snapshot.appendItems(items, toSection: section)
		apply(snapshot, animatingDifferences: false)
	}
}
