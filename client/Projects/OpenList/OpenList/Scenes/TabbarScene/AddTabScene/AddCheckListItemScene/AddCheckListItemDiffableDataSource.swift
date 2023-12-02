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
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			snapshot.appendItems([checkListItem], toSection: .selectItem)
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
	
	func deleteCheckListItem(with id: UUID, section: Section) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			if let placeholderIndex = snapshot.indexOfItem(AddCheckListItemPlaceholderItem()) {
				snapshot.deleteItems([AddCheckListItemPlaceholderItem()])
			}
			guard
				var items = snapshot.itemIdentifiers(inSection: section) as? [CheckListItem],
				let removeIndex = items.firstIndex(where: {$0.id == id})
			else { return }
			snapshot.deleteItems(items)
			items.remove(at: removeIndex)
			snapshot.appendItems(items, toSection: section)
			apply(snapshot, animatingDifferences: true)
		}
	}
	
	func getSelectedCheckListItem() -> [CheckListItem] {
		let snapshot = snapshot()
		guard let items = snapshot.itemIdentifiers(inSection: .selectItem) as? [CheckListItem] else { return [] }
		return items
	}
	
	func deletePlaceHolder() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = self.snapshot()
			// Placeholder를 삭제합니다
			if let placeholderIndex = snapshot.indexOfItem(AddCheckListItemPlaceholderItem()) {
				snapshot.deleteItems([AddCheckListItemPlaceholderItem()])
			}
			self.apply(snapshot, animatingDifferences: false)
		}
	}
	
	func appendPlaceHolder() {
		updateSection(with: [AddCheckListItemPlaceholderItem()], to: .selectItem)
	}
}

private extension AddCheckListItemDiffableDataSource {
	func makeSections() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = AddCheckListItemSnapshot()
			snapshot.appendSections([.selectItem, .aiItem])
			snapshot.appendItems([AddCheckListItemPlaceholderItem()], toSection: .selectItem)
			apply(snapshot, animatingDifferences: false)
		}
	}
	
	func updateSection(with items: [AnyHashable], to section: Section) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			var snapshot = snapshot()
			_ = snapshot.itemIdentifiers(inSection: section)
			snapshot.appendItems(items, toSection: section)
			apply(snapshot, animatingDifferences: false)
		}
	}
}
