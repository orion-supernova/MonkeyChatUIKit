//
//  SettingsViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - UI Elements
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.text = "Daha yapamadım mk"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        return label
    }()

    private let notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Notifications:"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    var notificationsCheckbox: UIButton = {
        let button = NotificationsCheckBox(type: .system)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Properties
    let currentUserString = UserDefaults.standard.string(forKey: "currentUser")
    let viewmodel = SettingsViewModel()
    var isChecked: Bool = true {
        didSet {
            if isChecked == true {
                notificationsCheckbox.setImage(UIImage(systemName: "bell"), for: .normal)
            } else {
                notificationsCheckbox.setImage(UIImage(systemName: "bell.slash"), for: .normal)
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }

    override func viewDidLayoutSubviews() {
        self.title = "Settings"
        view.backgroundColor = .systemBackground
    }

    // MARK: - Lifecycle
    func setup() {
        view.addSubview(mainLabel)
        view.addSubview(notificationsLabel)
        view.addSubview(notificationsCheckbox)
    }

    func layout() {
        let navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!

        mainLabel.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
        notificationsLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBarHeight*2)
            make.left.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
        notificationsCheckbox.snp.makeConstraints { make in
            make.centerY.equalTo(notificationsLabel.snp.centerY)
            make.left.equalTo(notificationsLabel.snp.right)
            make.width.height.equalTo(40)
        }
    }

    // MARK: - Actions
    @objc func checkBoxAction() {
        // If the user is registered, remove it and vice versa.
        if isChecked {
            viewmodel.unsubscribeForNewMessages()
        } else {
            viewmodel.subscribeForNewMessages(showAlert: true)
        }
        isChecked = !isChecked
    }

}
