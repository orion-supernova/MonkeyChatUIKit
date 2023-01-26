//
//  EULAViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 31.08.2022.
//

import UIKit
import SnapKit
import WebKit

class EULAViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()

    private lazy var checkbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        button.addTarget(self, action: #selector(checkboxAction), for: .touchUpInside)
        return button
    }()

    private lazy var checkboxLabel: UILabel = {
        let label = UILabel()
        label.text = "I agree to your End User License Agreement."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(UIColor.monkeyOrange, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setup()
        layout()
        loadWebView()
    }

    // MARK: - Setup & Layout
    private func setup() {
        view.addSubview(webView)
        view.addSubview(checkbox)
        view.addSubview(checkboxLabel)
        view.addSubview(continueButton)
    }

    private func layout() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
        }

        checkbox.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.size.equalTo(30)
        }

        checkboxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkbox.snp.centerY)
            make.left.equalTo(checkbox.snp.right).offset(5)
            make.right.equalTo(-10)
        }

        continueButton.snp.makeConstraints { make in
            make.top.equalTo(checkboxLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(180)
        }
    }

    // MARK: - Private Methods
    private func loadWebView() {
        COLLECTION_WEBLINKS.document("weblinks").getDocument { snapshot, error in
            guard let snapshot, error == nil else { return }
            guard let dict = snapshot.data() else { return }
            let url = URL(string: dict["eula"] as? String ?? "")!
            self.webView.load(URLRequest(url: url))
        }
    }

    func configureLoginView(completion: @escaping (UITabBarController) -> Void) {
        let tabController = UITabBarController()
        let vc1 = UINavigationController(rootViewController: ChatRoomListViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        tabController.viewControllers = [vc1, vc2]
        tabController.tabBar.tintColor = .systemPink

        vc1.tabBarItem.image = UIImage(systemName: "list.bullet")
        vc2.tabBarItem.image = UIImage(systemName: "gear")

        vc1.title = "MonkeyList"
        vc2.title = "Settings"
        completion(tabController)
    }

    // MARK: - Actions
    @objc func continueButtonAction() {
        if checkbox.isSelected {
            AppGlobal.shared.eulaConfirmed = true
            self.configureLoginView { tabBar in
                let tabController = tabBar
                tabController.modalPresentationStyle = .fullScreen
                tabController.modalTransitionStyle = .crossDissolve
                self.present(tabController, animated: true, completion: nil)
            }
        } else {
            AlertHelper.simpleAlertMessage(viewController: self, title: "Not agreed", message: "You need to agree to our license in order to use the app.")
        }
    }

    @objc func checkboxAction() {
        checkbox.isSelected.toggle()
    }
}
