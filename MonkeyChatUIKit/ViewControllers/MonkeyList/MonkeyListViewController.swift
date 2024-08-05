//
//  MonkeyListViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 2.08.2023.
//

import UIKit
import SnapKit

class MonkeyListViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var usersTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "usersTableViewCell")
        return tableView
    }()

    // MARK: - Private Properties
    private var users: [[String: Any]] = [[:]]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.users.removeAll()
        usersTableView.reloadData()
    }

    // MARK: - Setup
    private func setup() {
        view.addSubview(closeButton)
        view.addSubview(searchBar)
        view.addSubview(usersTableView)

        usersTableView.addEmptyDataView(text: "Search for friends!", buttonText: nil)
    }

    // MARK: - Layout
    private func layout() {
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.size.equalTo(30)
            make.left.equalTo(10)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }

        usersTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - Private Methods
    private func fetchUsersWith(searchText: String) {
        self.users.removeAll()
        COLLECTION_USERS.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            guard error == nil else { return self.reloadTableView() }
            guard let snapshot else { return self.reloadTableView() }
            let documents = snapshot.documents
            guard documents.isEmpty == false else { return self.reloadTableView() }
            for user in documents {
                let dict = user.data()
                let username = dict["username"] as? String ?? ""
                if username.contains(searchText) {
                    self.users.append(user.data())
                    self.reloadTableView()
                }
            }
        }
    }

    private func reloadTableView() {
        users.isEmpty ? (usersTableView.addEmptyDataView(text: "No user found...", buttonText: nil)) : (usersTableView.removeEmptyView())
        usersTableView.reloadData()
    }

    // MARK: - Actions
    @objc private func closeButtonAction() {
        self.dismiss(animated: true)
    }
}

// MARK: - UISearchBar Delegate
extension MonkeyListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        guard let text = searchBar.text else {
            AlertHelper.alertMessage(title: "Empty Text", message: "You should enter some text in order to search, right?", okButtonText: "OK")
            return
        }
        fetchUsersWith(searchText: text.lowercased())
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.users.removeAll()
        reloadTableView()
    }
}

// MARK: - UITableView DataSource
extension MonkeyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersTableViewCell", for: indexPath)
        var usernames: [String] = []
        for user in users {
            let username = user["username"] as? String ?? ""
            usernames.append(username)
        }
        cell.textLabel?.text = "\(usernames[indexPath.row])"
        return cell
    }
}

// MARK: - UITableView Delegate
extension MonkeyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fcmTokenForUser = users[indexPath.row]["fcmToken"] as? String ?? ""
        let sender = PushNotificationSender()

//        sender.sendFriendRequest(to: fcmTokenForUser, title: "AHOY AHOY", body: "\(AppGlobal.shared.username ?? "") added you as a friend!", category: .friendCategory)

        AlertHelper.simpleAlertMessage(viewController: self, title: "Great", message: "Let's see if they confirm your request!")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
