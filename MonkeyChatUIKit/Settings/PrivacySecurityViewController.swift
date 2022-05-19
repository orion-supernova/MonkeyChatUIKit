//
//  PrivacySecurityViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 2.05.2022.
//

import UIKit
import SnapKit

class PrivacySecurityViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeleteMyAccount")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setup()
        layout()
        setDelegates()
    }

    // MARK: - Setup & Layout
    private func setup() {
        view.addSubview(tableView)
    }

    private func layout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Functions
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableView Delegate
extension PrivacySecurityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            AlertHelper.alertMessage(viewController: self, title: "Delete My Account", message: "We are sorry to hear that you want to delete your account. If  you want to delete your account and everything related to your account in our servers, you can send an email to muratcankoc@gmail.com with the subject \"MonkeyChat Account Removal\". Remember that this action can NOT be undone.") {
                    //
            }
        }
    }
}

// MARK: - UITableView DataSource
extension PrivacySecurityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteMyAccount", for: indexPath)
            cell.textLabel?.text = "Delete My Account"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
