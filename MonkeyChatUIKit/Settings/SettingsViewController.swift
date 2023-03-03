//
//  SettingsViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Account")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrivacySecurity")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Hehe")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Help")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    private let profilePictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
        setDelegates()
        customizeView()
    }

    override func viewDidLayoutSubviews() {

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppGlobal.shared.currentPage = .settings
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

    private func customizeView() {
        self.title = "Settings"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemPink
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            let vc = AccountViewController()
            vc.title = "Account"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = PrivacySecurityViewController()
            vc.title = "Privacy & Security"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            AlertHelper.alertMessage(viewController: self, title: "Hehe", message: "Hehe") {
                //
            }
        } else {
            AlertHelper.simpleAlertMessage(viewController: self, title: "Contact Us!", message: "For any report or question, you can contact us at info@walhallaa.com!")
        }
    }
}


// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Account", for: indexPath)
            cell.textLabel?.text = "Account"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacySecurity", for: indexPath)
            cell.textLabel?.text = "Privacy & Security"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Hehe", for: indexPath)
            cell.textLabel?.text = "Tap Tap"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Help", for: indexPath)
            cell.textLabel?.text = "Help"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell
        }
    }
}
