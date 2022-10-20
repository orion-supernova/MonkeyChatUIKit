//
//  ViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

class ChatRoomListViewController: UIViewController {

    private let emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any private room yet."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 20)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        return emptyLabel
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatRoomListTableViewCell.self, forCellReuseIdentifier: "ChatRoomListTableViewCell")
        tableView.rowHeight = 55
        return tableView
    }()

    // MARK: - Private Properties
    private var viewModel = ChatRoomListViewModel()

    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setDelegates()
        layout()
        fetchAndObserveChatRooms()
    }

    deinit {
    }

    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar() // It is called from willAppear because username might be updated.
        updateLastMessages()
        AppGlobal.shared.currentPage = .monkeyList
    }

    override func viewDidLayoutSubviews() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .systemBackground
    }

    // MARK: - Setup
    private func setup() {
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
    }

    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
    }

    private func layout() {
        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(40)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }

    // MARK: - Functions
    func configureNavigationBar() {
        // FIXME: - This function should not be called from willAppear. Only the username stuff might be called from there.
        let createChatRoomButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                                   target: self,
                                                   action: #selector(createChatRoomAction))
        navigationItem.rightBarButtonItems = [createChatRoomButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink

        let userSessionLabel : UILabel = {
            let label = UILabel()
            // If the user is using multiple devices, username should match for all. So we check the server first to see if there is a given username.
            getUsernameFromServer { usernameFromServer in
                guard !usernameFromServer.isEmpty else {
                    if let usernameTemp = AppGlobal.shared.username {
                        label.text = "Your username: \(usernameTemp.isEmpty ? "Anonymous" : usernameTemp)"
                    } else {
                        label.text = "Your username: Anonymous"
                    }
                    return
                }
                label.text = "Your username: \(usernameFromServer)"
                AppGlobal.shared.username = usernameFromServer
            }
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 10)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
            return label
        }()

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userSessionLabel)

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "MonkeyChat"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }

    // MARK: - Private Methods
    private func toggleEmptyView() {
        if viewModel.chatRooms.count == 0 {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }

    private func fetchAndObserveChatRooms() {
        viewModel.fetchChatRooms()
    }

    private func updateLastMessages() {
        //
    }

    private func getUsernameFromServer(completion: @escaping (String) -> Void) {
        COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").getDocument { snapshot, error in
            guard let snapshot else { return }
            let dict = snapshot.data()
            let username = dict?["username"] as? String
            completion(username ?? "")
        }
    }

    // MARK: - Actions
    @objc func createChatRoomAction() {
        viewModel.createRoomOrEnterRoomAction(target: self)
    }
}

// MARK: UITableViewDataSource
extension ChatRoomListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomListTableViewCell", for: indexPath) as? ChatRoomListTableViewCell else { return UITableViewCell() }
        cell.configureCell(chatRoom: viewModel.chatRooms[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatRooms.count
    }
}

// MARK: UITableView Delegate
extension ChatRoomListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = ChatRoomViewController(chatRoom: viewModel.chatRooms[indexPath.row])
        AppGlobal.shared.lastEnteredChatRoomID = viewModel.chatRooms[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
// MARK: ChatRoomListViewModel Delegate
extension ChatRoomListViewController: ChatRoomListViewModelDelegate {
    func didChangeDataSource() {
        DispatchQueue.main.async {
            self.toggleEmptyView()
            UIView.transition(with: self.tableView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
        }
    }
}

