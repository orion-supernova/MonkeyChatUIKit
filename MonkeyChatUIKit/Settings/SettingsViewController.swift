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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Username")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Logout")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    private let profilePictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        return imageView
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
        super.viewDidLoad()

        setup()
        layout()
        setDelegates()
        addObservers()
    }

    override func viewDidLayoutSubviews() {
        self.title = "Settings"
        view.backgroundColor = .systemBackground
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

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("reloadTableView"), object: nil)
    }

    // MARK: - Actions
    @objc func logoutAction() {
        LottieHUD.shared.show()
        AuthManager.shared.signOut {
            let viewController = AuthViewController()
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
            LottieHUD.shared.dismiss()
        }
    }

    @objc func reloadTableView() {
        tableView.reloadData()
    }

    //MARK: - Functions
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
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

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            let vc = UsernameViewController()
            vc.title = "Edit Profile"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            logoutAction()
        }
    }
}


// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
            cell.textLabel?.textColor = .red
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            return cell
        }

    }
}
