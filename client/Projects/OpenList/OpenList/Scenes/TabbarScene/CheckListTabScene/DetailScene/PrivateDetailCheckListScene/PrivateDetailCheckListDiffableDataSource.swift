//
//  DetailCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

struct PrivateCheckListPlaceholderItem: Hashable {}

typealias PrivateCheckListDataSource = UITableViewDiffableDataSource<
	PrivateDetailCheckListDiffableDataSource.Section,
	AnyHashable
>
typealias PrivateCheckListSnapshot = NSDiffableDataSourceSnapshot<
	PrivateDetailCheckListDiffableDataSource.Section,
	AnyHashable
>

final class PrivateDetailCheckListDiffableDataSource: PrivateCheckListDataSource {
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

extension PrivateDetailCheckListDiffableDataSource {
	func appendCheckListItem(_ checkListItem: CheckListItem) {
		var snapshot = snapshot()
		snapshot.appendItems([checkListItem], toSection: .checkList)
		apply(snapshot, animatingDifferences: false)
	}
	
	func updateCheckList(_ checkList: [CheckListItem]) {
		updateSection(with: checkList, to: .checkList)
	}
	
	func updateCheckListItem(_ item: CheckListItem) {
		var snapshot = snapshot()
		guard var items = snapshot.itemIdentifiers(inSection: .checkList) as? [CheckListItem] else { return }
		snapshot.deleteItems(items)
		if let index = items.firstIndex(where: { $0.id == item.id}) {
			items[index].title = item.title
			items[index].isChecked = item.isChecked
		} else {
			items.append(item)
		}
		snapshot.appendItems(items, toSection: .checkList)
		apply(snapshot, animatingDifferences: false)
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
		updateSection(with: [PrivateCheckListPlaceholderItem()], to: .placeholder)
	}
}

private extension PrivateDetailCheckListDiffableDataSource {
	func makeSections() {
		var snapshot = PrivateCheckListSnapshot()
		snapshot.appendSections([.checkList, .placeholder])
		snapshot.appendItems([PrivateCheckListPlaceholderItem()], toSection: .placeholder)
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
