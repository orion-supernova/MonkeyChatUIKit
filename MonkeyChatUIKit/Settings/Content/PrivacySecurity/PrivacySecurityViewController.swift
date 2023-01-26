//
//  PrivacySecurityViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 2.05.2022.
//

import UIKit
import SnapKit
import WebKit

class PrivacySecurityViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrivacyPolicyTermsAndConditions")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Eula")
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

    // MARK: - Private Methods
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableView Delegate
extension PrivacySecurityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var url: URL?

        let viewModel = PrivacySecurityViewModel()
        viewModel.getWebLinks { success in
            guard success else { return }
            if indexPath.row == 0 {
                url = URL(string: viewModel.policyURLString ?? "")
            } else if indexPath.row == 1 {
                url = URL(string: viewModel.eulaURLString ?? "")
            }
            guard let url else { return }
            let webView = WebViewController(url: url)
            self.present(webView, animated: true)
        }
    }
}

// MARK: - UITableView DataSource
extension PrivacySecurityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyPolicyTermsAndConditions", for: indexPath)
            cell.textLabel?.text = "Privacy Policy & Terms And Conditions"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Eula", for: indexPath)
            cell.textLabel?.text = "EULA"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
