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
        button.setTitleColor(UIColor(named: "Black-White"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.sizeToFit()
        button.addTarget(self, action: #selector(usernameButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var userIDLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        return label
    }()

    private lazy var addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Friend", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(addFriendButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var friendRequestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Requests", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(friendRequestsButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MonkeyListCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - Private Properties
    private var viewModel = MonkeyListViewModel()
    private var friends: [String] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        customizeNavigationBar()
        getProfilePicture()
    }

    override func viewDidLayoutSubviews() {
        self.title = "MonkeyList"
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUsername()
        getFriends()
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
        view.addSubview(userIDLabel)
        view.addSubview(addFriendButton)
        view.addSubview(friendRequestsButton)
        view.addSubview(dividerView)
        view.addSubview(tableView)
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

        userIDLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameButton.snp.bottom)
            make.left.equalTo(2)
            make.right.equalTo(-10)
            make.height.greaterThanOrEqualTo(30)
        }

        addFriendButton.snp.makeConstraints { make in
            make.top.equalTo(userIDLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
//            make.right.equalTo(friendRequestsButton.snp.left)
            make.height.equalTo(30)
        }

        friendRequestsButton.snp.makeConstraints { make in
            make.top.equalTo(addFriendButton.snp.top)
//            make.left.equalTo(addFriendButton.snp.right)
            make.right.equalTo(-5)
            make.height.equalTo(addFriendButton.snp.height)
        }

        dividerView.snp.makeConstraints { make in
            make.top.equalTo(addFriendButton.snp.bottom).offset(2)
            make.left.equalTo(2)
            make.right.equalTo(-2)
            make.height.equalTo(2)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(2)
            make.left.right.bottom.equalToSuperview()
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
            self.userIDLabel.text = "userID:\n\(userID)"
        }
    }

    private func getProfilePicture() {
//        let profilePictureExists = UserDefaults.standard.bool(forKey: "ProfilePictureExists")
//        guard profilePictureExists else { return }

        let viewModel = ProfileViewModel()
        viewModel.getProfilePictureFromServer() { imageURL in
            guard imageURL.isEmpty == false else { return }
            self.profileIconImageView.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { result in
                switch result {
                    case .success(let value):
                        print("Image: \(value.image). Got from: \(value.cacheType)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            })
        }


//        viewModel.getProfilePictureFromDisk { [weak self] (success, image) in
//            guard let self = self else { return }
//            guard success else {
//                AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Something went wrong while fetching profile picture.")
//                self.profileIconImageView.image = UIImage(systemName: "person")
//                return
//            }
//            self.profileIconImageView.image = image
//        }

    }

    private func getFriends() {
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).collection("friends").getDocuments { [weak self ] snapshot, error in
            guard let self else { return }
            guard let snapshot else {
                self.reloadTableView()
                return
            }
            let friends = snapshot.documents
            guard friends.isEmpty == false else { return self.reloadTableView() }
            for friend in friends {
                let dict = friend.data()
                let username = dict["username"] as? String ?? ""
                self.friends.append(username)
                self.reloadTableView()
            }
        }
    }

    private func reloadTableView() {
        friends.isEmpty ? (tableView.addEmptyDataView(text: "You don't have any friends right now.\n\nBut don't worry, you can make lots of them if you want to!", buttonText: nil)) : (tableView.removeEmptyView())
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func profileImageIconAction() {
        let viewController = RoomImageViewController(profileImage: self.profileIconImageView.image ?? UIImage(systemName: "person")!)
        viewController.delegate = self
        viewController.view.backgroundColor = .systemBackground
        self.present(viewController, animated: true)
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.allowsEditing = true
//        present(imagePickerController, animated: true)
    }

    @objc func addFriendButtonAction() {
        let viewController = MonkeyListViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true)
    }

    @objc func friendRequestsButtonAction() {
        let viewController = FriendRequestsViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true)
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
// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonkeyListCell", for: indexPath)
        cell.textLabel?.text = "\(friends[indexPath.row])"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
}

// MARK: - UITableView Delegate
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

//        LottieHUD.shared.show()
//        let viewModel = ProfileViewModel()
//        viewModel.uploadProfilePictureToServer(image: image) { success in
//            guard success else {
//                AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Something went wrong.")
//                return
//            }
//        }



//        viewModel.saveProfilePictureToDisk(image: image) { [weak self] success in
//            guard let self = self else { return }
//            guard success else {
//                AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Something went wrong.")
//                return
//            }
//            UserDefaults.standard.set(true, forKey: "ProfilePictureExists")
//            self.profileIconImageView.image = image
//            LottieHUD.shared.dismiss()
//        }






    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - RoomImageViewController Delegate
extension ProfileViewController: RoomImageViewControllerDelegate {
    func didChangeImage(with image: UIImage) {
        UserDefaults.standard.set(true, forKey: "ProfilePictureExists")
        self.profileIconImageView.image = image
    }
}
