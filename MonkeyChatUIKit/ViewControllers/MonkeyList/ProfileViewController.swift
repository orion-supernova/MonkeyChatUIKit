//
//  MonkeyListViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 14.03.2022.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var  usernameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your username:"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.sizeToFit()
        button.addTarget(self, action: #selector(usernameButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MonkeyListCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - Private Properties
    private var viewModel = MonkeyListViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        customizeNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        self.title = "MonkeyList"
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUsername()
    }

    // MARK: - Setup
    private func setup() {
        setDelegates()
        view.addSubview(usernameTitleLabel)
        view.addSubview(usernameButton)
    }

    private func layout() {
        usernameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(2)
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }
        usernameButton.snp.makeConstraints { make in
            make.top.equalTo(usernameTitleLabel.snp.bottom).offset(2)
            make.left.equalTo(2)
            make.height.equalTo(15)
        }
    }

    // MARK: - Private Functions
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchFriends() {
        
    }

    private func customizeNavigationBar() {
        let addFriendButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                   target: self,
                                                   action: #selector(addFriendButtonAction))
        navigationItem.rightBarButtonItems = [addFriendButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "MonkeyList"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }

    private func getUsername() {
        COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot else { return }
            let dict = snapshot.data()
            let username = dict?["username"] as? String
            self.usernameButton.setTitle("@" + (username ?? ""), for: .normal)
        }
    }

    // MARK: - Actions
    @objc func addFriendButtonAction() {
        print("HEDE")
    }

    @objc private func usernameButtonAction() {
        AlertHelper.alertMessage(viewController: self, title: "Username", message: "Do you want to change your username?") { [weak self] in
            guard let self = self else { return }
            let viewController = UsernameViewController()
            self.present(viewController, animated: true)
        }

    }
    
}
//MARK: - UITableView Delegate
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonkeyListCell", for: indexPath)
        cell.textLabel?.text = "hmmm"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

//MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
