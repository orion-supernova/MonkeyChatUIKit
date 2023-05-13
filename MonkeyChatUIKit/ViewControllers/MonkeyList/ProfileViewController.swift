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
    private lazy var profileIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var  usernameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()

    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
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
        getProfilePicture()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profileIconImageView.layer.cornerRadius = 50
    }

    // MARK: - Setup
    private func setup() {
        setDelegates()
        setGestureRecognizers()
        view.addSubview(profileIconImageView)
        view.addSubview(usernameButton)
    }

    // MARK: - Layout
    private func layout() {
        profileIconImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }

        usernameButton.snp.makeConstraints { make in
            make.top.equalTo(profileIconImageView.snp.bottom).offset(2)
            make.left.equalTo(2)
            make.height.equalTo(15)
        }
    }

    // MARK: - Private Functions
    private func setGestureRecognizers() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageIconAction))
        profileIconImageView.addGestureRecognizer(gesture)
    }

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
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot else { return }
            let dict = snapshot.data()
            let username = dict?["username"] as? String ?? ""
            self.usernameButton.setTitle("@" + (username.isEmpty ? "Anonymous" : username ), for: .normal)
        }
    }

    private func getProfilePicture() {
        let profilePictureExists = UserDefaults.standard.bool(forKey: "ProfilePictureExists")
        guard profilePictureExists else { return }
        let viewModel = ProfileViewModel()
        viewModel.getProfilePictureFromDisk { [weak self] (success, image) in
            guard let self = self else { return }
            guard success else {
                AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Something went wrong while fetching profile picture.")
                self.profileIconImageView.image = UIImage(systemName: "person")
                return
            }
            self.profileIconImageView.image = image
        }
    }

    // MARK: - Actions
    @objc private func profileImageIconAction() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }

    @objc func addFriendButtonAction() {
        print("HEDE")
    }

    @objc private func usernameButtonAction() {
        AlertHelper.alertMessage(viewController: self, title: "Username", message: "Do you want to change your username?") { [weak self] in
            guard let self = self else { return }
            let viewController = UsernameViewController()
            viewController.delegate = self
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

extension ProfileViewController: UsernameViewControllerDelegate {
    func didChangeUsername(with username: String) {
        usernameButton.setTitle("@" + username, for: .normal)
    }
}

// MARK: - ImagePicker Delegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true)
        guard let image = image else { return }
        LottieHUD.shared.show()
        let viewModel = ProfileViewModel()
        viewModel.saveProfilePictureToDisk(image: image) { [weak self] success in
            guard let self = self else { return }
            guard success else {
                AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Something went wrong.")
                return
            }
            self.profileIconImageView.image = image
            LottieHUD.shared.dismiss()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
