//
//  WithDetailCheckListViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine
import UIKit

protocol WithDetailCheckListRoutingLogic: AnyObject {}

final class WithDetailCheckListViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 16
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
	}
	
	// MARK: - Properties
	private let router: WithDetailCheckListRoutingLogic
	private let viewModel: any WithDetailCheckListViewModelable
	private var cancellables: Set<AnyCancellable> = []
	private var dataSource: WithDetailCheckListDiffableDataSource?
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: CheckListHeaderView = .init()
	
	// Event Properties
	private var viewWillAppear: PassthroughSubject<Void, Never> = .init()
	private var socketConnet: PassthroughSubject<Void, Never> = .init()
	private var insert: PassthroughSubject<Range<String.Index>, Never> = .init()
	private var delete: PassthroughSubject<Range<String.Index>, Never> = .init()
	
	// MARK: - Initializers
	init(
		router: WithDetailCheckListRoutingLogic,
		viewModel: some WithDetailCheckListViewModelable
	) {
		self.router = router
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		makeDataSource()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
		socketConnet.send()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send(())
	}
}

// MARK: - Bind Methods
extension WithDetailCheckListViewController: ViewBindable {
	typealias State = WithDetailCheckListState
	typealias OutputError = Error
	
	func bind() {
		let input = WithDetailCheckListInput(
			viewWillAppear: viewWillAppear,
			socketConnet: socketConnet,
			insert: insert,
			delete: delete
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
		case let .title(title):
			headerView.configure(title: title!, isLocked: true)
		case let .update(content):
			print(content)
		case let .socketConnet(isConnect):
			print(isConnect)
		}
	}
	
	func handleError(_ error: OutputError) {}
}

// MARK: - View Methods
private extension WithDetailCheckListViewController {
	func setViewAttributes() {
		view.backgroundColor = UIColor.background
		setCheckListViewAttributes()
		setHeaderViewAttributes()
	}
	
	func setCheckListViewAttributes() {
		checkListView.keyboardDismissMode = .interactive
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.registerCell(LocalCheckListItem.self)
		checkListView.registerCell(CheckListItemPlaceholder.self)
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
		dataSource = WithDetailCheckListDiffableDataSource(
			tableView: checkListView,
			cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
				switch itemIdentifier {
				case is CheckListItem:
					let cell = tableView.dequeueCell(LocalCheckListItem.self, for: indexPath)
					guard let item = itemIdentifier as? CheckListItem else { return cell }
					cell.configure(with: item, indexPath: indexPath)
					cell.delegate = self
					return cell
					
				case is WithCheckListPlaceholderItem:
					let cell = tableView.dequeueCell(CheckListItemPlaceholder.self, for: indexPath)
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
extension WithDetailCheckListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return LayoutConstant.checkListItemHeight
	}
	
	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		switch indexPath.section {
		case 0:
			let configuration = UISwipeActionsConfiguration(actions: [deleteSwipeAction(at: indexPath)])
			configuration.performsFirstActionWithFullSwipe = false
			return configuration
			
		default:
			return nil
		}
	}
	
	func deleteSwipeAction(at indexPath: IndexPath) -> UIContextualAction {
		let action = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completion in
			self?.dataSource?.deleteCheckListItem(at: indexPath)
			completion(true)
		}
		action.image = UIImage(systemName: "trash")
		action.backgroundColor = .red
		return action
	}
}

// MARK: - LocalCheckListItemDelegate
extension WithDetailCheckListViewController: LocalCheckListItemDelegate {
	func textFieldDidEndEditing(
		_ textField: CheckListItemTextField,
		cell: LocalCheckListItem,
		indexPath: IndexPath
	) {
		if let text = textField.text, !text.isEmpty {
			// 로컬에 저장합니다.
			dataSource?.updateCheckListItemString(at: indexPath, with: text)
		} else {
			dataSource?.deleteCheckListItem(at: indexPath)
		}
	}
	
	func textField(
		_ textField: CheckListItemTextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		guard let text = textField.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		guard updatedText.count <= 30 else { return false }
		
		switch range.length {
		case 0:
			insert.send(stringRange)
		case 1:
			delete.send(stringRange)
		default:
			return false
		}
		
		return true
	}
}

// MARK: - WithCheckListItemPlaceholderDelegate
extension WithDetailCheckListViewController: CheckListItemPlaceholderDelegate {
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, indexPath: IndexPath) {
		guard let text = textField.text else { return }
		textField.text = nil
		dataSource?.appendCheckListItem(CheckListItem(title: text, isChecked: false))
		dataSource?.updatePlaceholder()
	}
}
