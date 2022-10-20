//
//  MonkeyListViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 14.03.2022.
//

import UIKit

class MonkeyListViewController: UIViewController {
    // MARK: - UI Elements
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
        setDelegates()
        customizeNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        self.title = "MonkeyList"
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    // MARK: - Setup
    func setup() {
        view.addSubview(tableView)
    }

    func layout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

    // MARK: - Actions
    @objc func addFriendButtonAction() {
        print("HEDE")
    }
    
}
//MARK: - UITableView Delegate
extension MonkeyListViewController: UITableViewDataSource {
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
extension MonkeyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
