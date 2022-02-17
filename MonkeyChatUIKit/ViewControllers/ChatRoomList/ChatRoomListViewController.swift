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
        emptyLabel.text = "You don't have any private booth yet."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 20)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        return emptyLabel
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatRoomListTableViewCell.self, forCellReuseIdentifier: "ChatRoomListTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    // MARK: - Private Properties
    private var viewModel = ChatRoomListViewModel()
    let currentUserString = UserDefaults.standard.string(forKey: "currentUser")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setTableViewDelegates()
        layout()
        fetchAndObserveChatRooms()
    }

    deinit {
    }

    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        updateLastMessages()
    }

    override func viewDidLayoutSubviews() {
        navigationItem.backButtonTitle = ""
    }

    // MARK: - Setup
    private func setup() {
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
    }

    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
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
        // MARK: - Configure Navigation Bar
        let createChatRoomButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                                   target: self,
                                                   action: #selector(createChatRoomAction))
        navigationItem.rightBarButtonItems = [createChatRoomButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink

        let currentUserString = UserDefaults.standard.string(forKey: "currentUser")
        let userSessionLabel : UILabel = {
            let label = UILabel()
            label.text = "Logged as: \(currentUserString ?? "Guest")"
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 10)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
            return label
        }()

        if currentUserString == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userSessionLabel)
        } else {
            userSessionLabel.text = "Logged as Guest"
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userSessionLabel)
        }

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
        } else {
            emptyLabel.isHidden = false
        }
    }

    private func fetchAndObserveChatRooms() {
        viewModel.fetchChatRooms { [weak self] in
            self?.toggleEmptyView()
            self?.tableView.reloadData()
        }
    }

    private func updateLastMessages() {
        //
    }

    // MARK: - Actions
    @objc func createChatRoomAction() {
        viewModel.createRoomOrEnterRoomAction { roomCode in
            //
        }
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

// MARK: UITableViewDelegate
extension ChatRoomListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = ChatRoomViewController(chatRoom: viewModel.chatRooms[indexPath.row])
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

