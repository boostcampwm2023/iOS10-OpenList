//
//  AddCheckListItemViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine
import UIKit

protocol AddCheckListItemRoutingLogic: AnyObject {
	func routeToMinorCategoryView()
	func dismiss()
}

final class AddCheckListItemViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 10
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
		static let navigationBarHeight = 56.0
	}
	
	// MARK: - Properties
	private let router: AddCheckListItemRoutingLogic
	private let viewModel: any AddCheckListItemViewModelable
	private var cancellables: Set<AnyCancellable> = []
	private var dataSource: AddCheckListItemDiffableDataSource?
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: AddCheckListItemHeaderView = .init()
	private let nextButton = ConfirmButton(title: "완료")
	private var navigationBar: OpenListNavigationBar = .init(isBackButtonHidden: false)
	
	// Event Properties
	private var configureHeaderView: PassthroughSubject<Void, Never> = .init()
	private var viewLoad: PassthroughSubject<Void, Never> = .init()
	private var nextButtonDidTappedSubject: PassthroughSubject<[CheckListItem], Never> = .init()
	
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
		configureHeaderView.send()
		LoadingIndicator.showLoading()
		viewLoad.send()
	}
}

// MARK: - Bind Methods
extension AddCheckListItemViewController: ViewBindable {
	typealias State = AddCheckListItemState
	typealias OutputError = Error
	
	func bind() {
		let input = AddCheckListItemInput(
			configureHeaderView: configureHeaderView,
			viewDidLoad: viewLoad,
			nextButtonDidTap: nextButtonDidTappedSubject
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
		case .configureHeader(let categoryInfo):
			updateView(categoryInfo: categoryInfo)
				
		case .viewDidLoad(let items):
			dataSource?.updateAiItem(
				items.map {
					return CheckListItem(itemId: UUID(), title: $0.content, isChecked: false)
				}
			)
			LoadingIndicator.hideLoading()
			
		case .dismiss:
			router.dismiss()
			
		case .error(let error):
			guard let error else { return }
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
			headerView.configure(title: categoryInfo.title, tags: nil)
			return
		}
		headerView.configure(title: categoryInfo.title, tags: [mainCategory, subCategory, minorCategory])
	}
}

// MARK: - View Methods
private extension AddCheckListItemViewController {
	func setViewAttributes() {
		view.backgroundColor = .background
		setNavigationBar()
		setCheckListViewAttributes()
		setHeaderViewAttributes()
		setNextButtonAttributes()
	}
	
	func setCheckListViewAttributes() {
		checkListView.backgroundColor = .background
		checkListView.keyboardDismissMode = .interactive
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.registerCell(SelectCheckListCell.self)
		checkListView.registerCell(AiCheckListCell.self)
		checkListView.registerCell(AddCheckListItemPlaceholder.self)
		checkListView.registerHeaderFooter(AddCheckListItemTableViewSectionHeader.self)
		checkListView.sectionHeaderTopPadding = 0
		checkListView.delegate = self
		checkListView.allowsSelection = true
		checkListView.separatorStyle = .none
		/// 테이블 뷰 영역 터치 시 키보드를 내린다.
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tapGesture.cancelsTouchesInView = true
		checkListView.addGestureRecognizer(tapGesture)
	}
	
	func setNavigationBar() {
		navigationBar.delegate = self
		navigationBar.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setHeaderViewAttributes() {
		headerView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setNextButtonAttributes() {
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		nextButton.addTarget(self, action: #selector(nextButtonDidTapped), for: .touchUpInside)
	}
	
	func setViewHierarchies() {
		view.addSubview(navigationBar)
		view.addSubview(checkListView)
		view.addSubview(headerView)
		view.addSubview(nextButton)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
			navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			navigationBar.heightAnchor.constraint(equalToConstant: LayoutConstant.navigationBarHeight),
			
			headerView.topAnchor.constraint(
				equalTo: navigationBar.bottomAnchor,
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
			headerView.heightAnchor.constraint(equalToConstant: 50),
			checkListView.topAnchor.constraint(
				equalTo: headerView.bottomAnchor,
				constant: LayoutConstant.spacingBetweenTitleAndCheckList
			),
			checkListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			checkListView.bottomAnchor.constraint(
				equalTo: nextButton.topAnchor,
				constant: -LayoutConstant.spacingBetweenTitleAndCheckList
			),
			checkListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			nextButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
			nextButton.leadingAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.leadingAnchor,
				constant: LayoutConstant.horizontalPadding
			),
			nextButton.trailingAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			)
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
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 1 { return 0 }
		return 28
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 1 { return nil }
		let header = tableView.dequeueHeaderFooter(AddCheckListItemTableViewSectionHeader.self)
		header.delegate = self
		header.configure(section: section)
		return header
	}
	
	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		// 사용자가 삭제 액션을 수행하면 호출될 핸들러 함수를 정의합니다.
		switch indexPath.section {
		case 1:
			return nil
		default:
			let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, _) in
				self?.dataSource?.deleteCheckListItem(at: indexPath)
			}
			deleteAction.backgroundColor = .red
			let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
			return swipeConfig
		}
	}
}

// MARK: - SelectCheckListItemDelegate
extension AddCheckListItemViewController: SelectCheckListCellDelegate {
	func checkButtonDidToggled(_ textView: OpenListTextView, cell: SelectCheckListCell, cellId: UUID) {
		guard let text = textView.text else { return }
		dataSource?.deleteCheckListItem(with: cellId, section: .selectItem)
		dataSource?.updateAiItem([
			CheckListItem(
				itemId: cellId,
				title: text,
				isChecked: false)
		])
	}
	
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: SelectCheckListCell,
		indexPath: IndexPath
	) {
		guard let text = textView.text, text.isEmpty  else { return }
		dataSource?.deleteCheckListItem(at: indexPath)
	}
	
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		cellId: UUID
	) -> Bool {
		guard let text = textView.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		return updatedText.count <= 30
	}
	
	func textViewDidChange(_ textView: OpenListTextView) {
		checkListView.beginUpdates()
		checkListView.endUpdates()
	}
}

// MARK: - AiCheckListItemDelegate
extension AddCheckListItemViewController: AiCheckListCellDelegate {
	func checklistButtonDidToggle(_ textView: OpenListTextView, cell: AiCheckListCell, cellId: UUID) {
		guard let text = textView.text else { return }
		dataSource?.deleteCheckListItem(with: cellId, section: .aiItem)
		dataSource?.updateSelectItem([
			CheckListItem(
				itemId: cellId,
				title: text,
				isChecked: true)
		])
	}
	
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: AiCheckListCell,
		indexPath: IndexPath
	) {
		guard let text = textView.text, text.isEmpty  else { return }
		dataSource?.deleteCheckListItem(at: indexPath)
	}
}

// MARK: - WithCheckListItemPlaceholderDelegate
extension AddCheckListItemViewController: AddCheckListItemPlaceholderDelegate {
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		guard let text = textView.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		return updatedText.count <= 30
	}
	
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textViewDidEndEditing(_ textView: OpenListTextView, indexPath: IndexPath) {
		guard let text = textView.text else { return }
		dataSource?.updateSelectItem([.init(itemId: UUID(), title: text, isChecked: true)])
	}
}

extension AddCheckListItemViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(
		_ navigationBar: OpenListNavigationBar,
		didTapBackButton button: UIButton
	) {
		router.routeToMinorCategoryView()
	}
	
	func openListNavigationBar(
		_ navigationBar: OpenListNavigationBar,
		didTapBarItem item: OpenListNavigationBarItem
	) {
		return
	}
}

extension AddCheckListItemViewController {
	@objc func nextButtonDidTapped() {
		guard let dataSource else { return }
		nextButtonDidTappedSubject.send(dataSource.getCheckListItem(section: .selectItem))
	}
}

extension AddCheckListItemViewController: AddCheckListItemTableViewHeaderDelegate {
	func toggleAllSelected(at section: Int?) {
		guard let section = section else { return }
		if section == 0 {
			guard let selectedItems = dataSource?.getCheckListItem(section: .selectItem) else { return }
			dataSource?.deleteItems(selectedItems)
			selectedItems.forEach {
				dataSource?.updateAiItem([
					CheckListItem(
						itemId: $0.id,
						title: $0.title,
						isChecked: false
					)
				])
			}
			return
		}
	}
	
	func toggleAllUnSelected(at section: Int?) {
		guard let section = section else { return }
		if section == 2 {
			guard let unselectedItems = dataSource?.getCheckListItem(section: .aiItem) else { return }
			dataSource?.deleteItems(unselectedItems)
			unselectedItems.forEach {
				dataSource?.updateSelectItem([
					CheckListItem(
						itemId: $0.id,
						title: $0.title,
						isChecked: true
					)
				])
			}
			return
		}
	}
}
