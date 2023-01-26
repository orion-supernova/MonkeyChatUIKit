    //
    //  AccountViewController.swift
    //  MonkeyChatUIKit
    //
    //  Created by Murat Can KOÇ on 2.05.2022.
    //

import UIKit
import SnapKit

class AccountViewController: UIViewController {

        // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Username")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Logout")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeleteMyAccount")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.textAlignment = .center
        textField.returnKeyType = .done
        return textField
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        return button
    }()

        // MARK: - Private Properties
    let viewmodel = SettingsViewModel()

        // MARK: - Lifecycle
    override func viewDidLoad() {
        setup()
        layout()
        setDelegates()
        addObservers()
    }

    override func viewDidLayoutSubviews() {
        
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

    //MARK: - Functions
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("reloadTableView"), object: nil)
    }

    @objc func reloadTableView() {
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc func logoutAction() {
        AlertHelper.alertMessage(viewController: self, title: "Logout", message: "Do you want to logout from MonkeyChat?") {
            LottieHUD.shared.show()
            AuthManager.shared.signOut {
                let viewController = AuthViewController()
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
                LottieHUD.shared.dismiss()
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension AccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            guard let username = textField.text else { return false }
            viewmodel.changeUsername(username: username)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

            // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            // make sure the result is under 16 characters
        return updatedText.count <= 13
    }

}

// MARK: - UITableView Delegate
extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = UsernameViewController()
            vc.title = "Edit Profile"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            logoutAction()
        } else {
            AlertHelper.alertMessage(viewController: self, title: "Delete My Account", message: "We are sorry to hear that you want to delete your account. If  you proceed, your account will be deleted and you will be removed from all the rooms you're currently in. But your messages will not be affected. Remember that this action can NOT be undone.") {
                let viewModel = AccountViewModel()
                viewModel.startDeleteUserAccount {[weak self] result in
                    guard let self = self else { return }
                    switch result {
                        case .success(_):
                            let viewController = AuthViewController()
                            viewController.modalPresentationStyle = .fullScreen
                            self.present(viewController, animated: true, completion: nil)
                        case .failure(let error):
                            AlertHelper.alertMessage(viewController: self, title: "Couldn't Delete Account", message: error.localizedDescription) {
                                //
                            }
                    }
                }
            }
        }
    }
}

// MARK: - UITableView DataSource
extension AccountViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Username", for: indexPath)
            cell.textLabel?.text = "Username: \(AppGlobal.shared.username ?? "")"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteMyAccount", for: indexPath)
            cell.textLabel?.text = "Delete My Account"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            return cell
        }
    }
}
