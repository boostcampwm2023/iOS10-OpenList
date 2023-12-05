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
	func receiveCheckListItem(with item: any ListItem) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			if item.title.isEmpty {
				self.deleteCheckListItem(at: item)
				return
			}
			var snapshot = snapshot()
			guard var items = snapshot.itemIdentifiers(inSection: .checkList) as? [WithCheckListItem] else { return }
			snapshot.deleteItems(items)
			if let index = items.firstIndex(where: { $0.id == item.id }) {
				items[index].title = item.title
			} else {
				guard let item = item as? WithCheckListItem else { return }
				items.append(item)
			}
			snapshot.appendItems(items, toSection: .checkList)
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func receiveCheckListItemWithName(with item: any ListItem, name: String) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			if item.title.isEmpty {
				guard let item = item as? WithCheckListItem else { return }
				self.deleteCheckListItem(at: item)
				return
			}
			var snapshot = snapshot()
			guard var items = snapshot.itemIdentifiers(inSection: .checkList) as? [WithCheckListItem] else { return }
			snapshot.deleteItems(items)
			if let index = items.firstIndex(where: { $0.id == item.id }) {
				items[index].title = item.title
			} else {
				guard let item = item as? WithCheckListItem else { return }
				items.append(item)
			}
			snapshot.appendItems(items, toSection: .checkList)
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func appendCheckListItem(_ checkListItem: any ListItem) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			switch checkListItem {
//			case is CheckListItem:
//				guard let item = checkListItem as? CheckListItem else { return }
//				snapshot.appendItems([item], toSection: .checkList)
//				
			case is WithCheckListItem:
				guard let item = checkListItem as? WithCheckListItem else { return }
				snapshot.appendItems([item], toSection: .checkList)
				
			default:
				return
			}
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func updateCheckList(_ checkList: [any ListItem]) {
		switch checkList {
			case is [CheckListItem]:
				guard let items = checkList as? [CheckListItem] else { return }
				updateSection(with: items, to: .checkList)
				
			case is [WithCheckListItem]:
				guard let items = checkList as? [WithCheckListItem] else { return }
				updateSection(with: items, to: .checkList)
				
			default:
				return
		}
	}
	
	func updateCheckListItemString(at indexPath: IndexPath, with text: String) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			guard var items = snapshot.itemIdentifiers(inSection: .checkList) as? [CheckListItem] else { return }
			snapshot.deleteItems(items)
			items[indexPath.row].title = text
			snapshot.appendItems(items, toSection: .checkList)
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func deleteCheckListItem(at indexPath: IndexPath) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			guard let item = itemIdentifier(for: indexPath) else { return }
			snapshot.deleteItems([item])
			apply(snapshot, animatingDifferences: true)
		}
	}
	
	func deleteCheckListItem(at item: any ListItem) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			guard
				var items = snapshot.itemIdentifiers(inSection: .checkList) as? [CheckListItem],
				let removeIndex = items.firstIndex(where: {$0.id == item.id})
			else { return }
			snapshot.deleteItems(items)
			items.remove(at: removeIndex)
			snapshot.appendItems(items, toSection: .checkList)
			apply(snapshot, animatingDifferences: true)
		}
	}
	
	func updatePlaceholder() {
		updateSection(with: [WithCheckListPlaceholderItem()], to: .placeholder)
	}
}

private extension WithDetailCheckListDiffableDataSource {
	func makeSections() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = WithCheckListSnapshot()
			snapshot.appendSections([.checkList, .placeholder])
			snapshot.appendItems([WithCheckListPlaceholderItem()], toSection: .placeholder)
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func updateSection(with items: [AnyHashable], to section: Section) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			let previousProducts = snapshot.itemIdentifiers(inSection: section)
			snapshot.deleteItems(previousProducts)
			snapshot.appendItems(items, toSection: section)
			apply(snapshot, animatingDifferences: false)
		}
	}
}
