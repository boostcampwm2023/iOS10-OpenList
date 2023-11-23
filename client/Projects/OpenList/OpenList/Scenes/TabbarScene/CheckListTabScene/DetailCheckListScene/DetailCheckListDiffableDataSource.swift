//
//  DetailCheckListDiffableDataSource.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

// 도메인 모델이 나오면 변경 예정
struct CheckListItem: Hashable, Identifiable {
	var id: UUID { itemId	}
	let itemId = UUID()
	var title: String
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
		updateSection(with: [CheckListPlaceholderItem()], to: .placeholder)
	}
}

private extension DetailCheckListDiffableDataSource {
	func makeSections() {
		var snapshot = CheckListSnapshot()
		snapshot.appendSections([.checkList, .placeholder])
		snapshot.appendItems([CheckListPlaceholderItem()], toSection: .placeholder)
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
