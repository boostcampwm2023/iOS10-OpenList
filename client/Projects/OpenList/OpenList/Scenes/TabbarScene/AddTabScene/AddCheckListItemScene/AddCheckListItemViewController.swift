//
//  AddCheckListItemViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine
import UIKit

protocol AddCheckListItemRoutingLogic: AnyObject { }

final class AddCheckListItemViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 10
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
	}
	
	// MARK: - Properties
  private let router: AddCheckListItemRoutingLogic
  private let viewModel: any AddCheckListItemViewModelable
  private var cancellables: Set<AnyCancellable> = []
	private var dataSource: AddCheckListItemDiffableDataSource?
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: AddCheckListItemHeaderView = .init()
	
	// Event Properties
	private var viewLoad: PassthroughSubject<Void, Never> = .init()

  // MARK: - Initializers
	init(
		router: AddCheckListItemRoutingLogic,
		viewModel: some AddCheckListItemViewModelable
	) {
		self.router = router
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

  @available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		
		makeDataSource()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
		viewLoad.send()
	}
}

// MARK: - Bind Methods
extension AddCheckListItemViewController: ViewBindable {
	typealias State = AddCheckListItemState
	typealias OutputError = Error

	func bind() {
		let input = AddCheckListItemInput(
			viewDidLoad: viewLoad
		)
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, output) in owner.render(output) }
			.store(in: &cancellables)
	}

	func render(_ state: State) {
		switch state {
		case .viewDidLoad(let items, let categoryInfo):
			updateView(categoryInfo: categoryInfo)
			dataSource?.updateAiItem(
				items.map {
					return CheckListItem(itemId: UUID(), title: $0.content, isChecked: false)
				}
			)
		case .error(let error):
			handleError(error)
		}
	}

	func handleError(_ error: OutputError) { }
}

// MARK: - Helper
private extension AddCheckListItemViewController {
	func updateView(categoryInfo: CategoryInfo) {
		guard
			let mainCategory = categoryInfo.mainCategory,
			let subCategory = categoryInfo.subCategory,
			let minorCategory = categoryInfo.minorCategory
		else {
			headerView.configure(title: categoryInfo.title, tags: ["", "", ""])
			return
		}
		headerView.configure(title: categoryInfo.title, tags: [mainCategory, subCategory, minorCategory])
	}
}

// MARK: - View Methods
private extension AddCheckListItemViewController {
	func setViewAttributes() {
		view.backgroundColor = .systemBackground
		
		setCheckListViewAttributes()
		setHeaderViewAttributes()
	}
	
	func setCheckListViewAttributes() {
		checkListView.keyboardDismissMode = .interactive
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.registerCell(SelectCheckListCell.self)
		checkListView.registerCell(AiCheckListCell.self)
		checkListView.registerCell(AddCheckListItemPlaceholder.self)
		checkListView.delegate = self
		checkListView.allowsSelection = false
		checkListView.separatorStyle = .none
		/// 테이블 뷰 영역 터치 시 키보드를 내린다.
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tapGesture.cancelsTouchesInView = true
		checkListView.addGestureRecognizer(tapGesture)
	}
	
	func setHeaderViewAttributes() {
		headerView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		view.addSubview(checkListView)
		view.addSubview(headerView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.topAnchor,
				constant: LayoutConstant.topPadding
			),
			headerView.leadingAnchor.constraint(
				equalTo: view.leadingAnchor,
				constant: LayoutConstant.horizontalPadding
			),
			headerView.trailingAnchor.constraint(
				lessThanOrEqualTo: view.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			checkListView.topAnchor.constraint(
				equalTo: headerView.bottomAnchor,
				constant: LayoutConstant.spacingBetweenTitleAndCheckList
			),
			checkListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			checkListView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
			checkListView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	@objc func hideKeyboard() {
		checkListView.endEditing(true)
	}
	
	func makeDataSource() {
		dataSource = AddCheckListItemDiffableDataSource(
			tableView: checkListView,
			cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
				switch itemIdentifier {
				case is CheckListItem:
					guard let item = itemIdentifier as? CheckListItem else { return nil }
					if item.isChecked {
						let cell = tableView.dequeueCell(SelectCheckListCell.self, for: indexPath)
						cell.configure(with: item, indexPath: indexPath)
						cell.delegate = self
						return cell
					} else {
						let cell = tableView.dequeueCell(AiCheckListCell.self, for: indexPath)
						cell.configure(with: item, indexPath: indexPath)
						cell.delegate = self
						return cell
					}
					
				case is AddCheckListItemPlaceholderItem:
					let cell = tableView.dequeueCell(AddCheckListItemPlaceholder.self, for: indexPath)
					cell.configure(indexPath: indexPath)
					cell.delegate = self
					return cell
					
				default:
					return nil
				}
			}
		)
	}
}

// MARK: - UITableViewDelegate
extension AddCheckListItemViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return LayoutConstant.checkListItemHeight
	}
	
	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		// 사용자가 삭제 액션을 수행하면 호출될 핸들러 함수를 정의합니다.
		let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, _) in
			self?.dataSource?.deleteCheckListItem(at: indexPath)
		}
		deleteAction.backgroundColor = .red
		let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
		return swipeConfig
	}
}

// MARK: - SelectCheckListItemDelegate
extension AddCheckListItemViewController: SelectCheckListCellDelegate {
	func checkButtonDidToggled(_ textField: CheckListItemTextField, cell: SelectCheckListCell, cellId: UUID) {
		dataSource?.deleteCheckListItem(with: cellId, section: .selectItem)
		dataSource?.updateAiItem([
			CheckListItem(
				itemId: cellId,
				title: textField.text!,
				isChecked: false)
		])
	}
	
	func textFieldDidEndEditing(
		_ textField: CheckListItemTextField,
		cell: SelectCheckListCell,
		indexPath: IndexPath
	) { }
	
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		cellId: UUID
	) -> Bool {
		guard let text = textField.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		return updatedText.count <= 30
	}
}

// MARK: - AiCheckListItemDelegate
extension AddCheckListItemViewController: AiCheckListCellDelegate {
	func checklistButtonDidToggle(_ textField: CheckListItemTextField, cell: AiCheckListCell, cellId: UUID) {
		dataSource?.deleteCheckListItem(with: cellId, section: .aiItem)
		dataSource?.updateSelectItem([
			CheckListItem(
				itemId: cellId,
				title: textField.text!,
				isChecked: true)
		])
	}

	func textFieldDidEndEditing(
		_ textField: CheckListItemTextField,
		cell: AiCheckListCell,
		indexPath: IndexPath
	) { }
}

// MARK: - WithCheckListItemPlaceholderDelegate
extension AddCheckListItemViewController: AddCheckListItemPlaceholderDelegate {
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		guard let text = textField.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		return updatedText.count <= 30
	}
	
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, indexPath: IndexPath) {
		guard let text = textField.text else { return }
		dataSource?.updateSelectItem([.init(itemId: UUID(), title: text, isChecked: true)])
		textField.text = nil
	}
}
