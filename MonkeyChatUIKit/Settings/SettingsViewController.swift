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

    // MARK: - Private Properties
    let currentUserString = UserDefaults.standard.string(forKey: "currentUser")

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
    }

    func layout() {
        mainLabel.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
    }

}
