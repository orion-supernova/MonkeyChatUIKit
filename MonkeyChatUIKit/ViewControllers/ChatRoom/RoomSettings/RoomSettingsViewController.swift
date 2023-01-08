//
//  RoomSettingsViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.06.2022.
//

import UIKit
import SnapKit
import Kingfisher

protocol RoomSettingsViewControllerDelegate: AnyObject {
    func didDeleteOrBlockRoom()
    func didChangeRoomName(with newName: String)
}

class RoomSettingsViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var roomIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemPink
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var roomIDTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        label.text = "Room ID:"
        return label
    }()

    private lazy var roomIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hexString: "9D9393")
        return label
    }()

    private lazy var roomNameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        label.text = "Room Name:"
        return label
    }()

    private lazy var roomNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hexString: "9D9393")
        return label
    }()

    private lazy var roomPasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        label.text = "Room Password:"
        return label
    }()

    private lazy var changeRoomNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change", for: .normal)
        button.setTitleColor(UIColor(hexString: "9D9393"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.addTarget(self, action: #selector(changeRoomNameButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var roomPasswordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private lazy var showHideRoomPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(showHideRoomButtonAction(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var seperatorOneView: UIView = {
        let view  = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private lazy var inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Invite Friends", for: .normal)
        button.addTarget(self, action: #selector(inviteButtonAction), for: .touchUpInside)
        button.backgroundColor = .secondarySystemBackground
        return button
    }()

    private lazy var blockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Block This Room", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(blockRoomAction), for: .touchUpInside)
        return button
    }()

    private lazy var membersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See The Members", for: .normal)
        button.setTitleColor(UIColor.secondaryLabel, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(membersButtonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Public Properties
    var chatRoom: ChatRoom?
    var navigationBarHeight: CGFloat = 0
    var tabbarHeight: CGFloat = 0
    weak var delegate: RoomSettingsViewControllerDelegate?

    // MARK: - Private Properties
    private var roomPassword = ""

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(chatRoom: ChatRoom) {
        super.init(nibName: nil, bundle: nil)
        self.chatRoom = chatRoom
        fetchAndObserverGroupImage()
        setLabelTexts()
        showHideRoomPasswordButton.isHidden = (chatRoom.password?.isEmpty ?? false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        configureNavigationBar()
        addGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roomIconImageView.layer.cornerRadius = 50 // It should be half of the size so it can be a cicle.
        roomIconImageView.clipsToBounds = true
        inviteButton.layer.cornerRadius = 5
        blockButton.layer.cornerRadius = 5
        membersButton.layer.cornerRadius = 5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppGlobal.shared.currentPage = .roomSettings
    }

    // MARK: - Seyup & Layout
    private func setup() {
        view.addSubview(mainContainerView)
        mainContainerView.addSubview(roomIconImageView)
        mainContainerView.addSubview(roomIDTitleLabel)
        mainContainerView.addSubview(roomIDLabel)
        mainContainerView.addSubview(roomNameTitleLabel)
        mainContainerView.addSubview(roomNameLabel)
        mainContainerView.addSubview(changeRoomNameButton)
        mainContainerView.addSubview(roomPasswordTitleLabel)
        mainContainerView.addSubview(roomPasswordLabel)
        mainContainerView.addSubview(showHideRoomPasswordButton)
        mainContainerView.addSubview(seperatorOneView)
        mainContainerView.addSubview(inviteButton)
        mainContainerView.addSubview(blockButton)
        mainContainerView.addSubview(membersButton)
    }

    private func layout() {
        navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!
        tabbarHeight = (tabBarController?.tabBar.frame.size.height)!

        mainContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-tabbarHeight)
        }
        
        roomIconImageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }

        roomIDTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(roomIconImageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(15)
        }

        roomIDLabel.snp.makeConstraints { make in
            make.top.equalTo(roomIDTitleLabel.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(15)
        }

        roomNameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(roomIDLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(15)
        }

        roomNameLabel.snp.makeConstraints { make in
            make.top.equalTo(roomNameTitleLabel.snp.bottom).offset(1)
            make.left.equalToSuperview()
            make.right.equalTo(-50)
            make.height.greaterThanOrEqualTo(15)
        }

        changeRoomNameButton.snp.makeConstraints { make in
            make.top.equalTo(roomNameLabel.snp.top)
            make.bottom.equalTo(roomNameLabel.snp.bottom)
            make.left.equalTo(roomNameLabel.snp.right)
            make.right.equalToSuperview()

        }

        roomPasswordTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(roomNameLabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
            make.right.equalTo(-50)
            make.height.equalTo(15)
        }

        roomPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(roomPasswordTitleLabel.snp.bottom).offset(1)
            make.left.equalToSuperview()
            make.right.equalTo(-50)
            make.height.greaterThanOrEqualTo(15)
        }

        showHideRoomPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(roomPasswordLabel.snp.top)
            make.bottom.equalTo(roomPasswordLabel.snp.bottom)
            make.left.equalTo(roomPasswordLabel.snp.right)
            make.right.equalToSuperview()
        }

        seperatorOneView.snp.makeConstraints { make in
            make.top.equalTo(roomPasswordLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        inviteButton.snp.makeConstraints { make in
            make.top.equalTo(seperatorOneView.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(180)
        }

        blockButton.snp.makeConstraints { make in
            make.top.equalTo(inviteButton.snp.top)
            make.right.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(180)
        }

        membersButton.snp.makeConstraints { make in
            make.top.equalTo(inviteButton.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(180)
        }
    }

    private func configureNavigationBar() {
        let deleteRoomButton = UIBarButtonItem(image: UIImage(systemName: "minus.circle"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(deleteRoomButtonAction))
        navigationItem.rightBarButtonItems = [deleteRoomButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
    }

    private func addGestures() {
        let roomIconImageViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(roomIconImageViewRecognizerAction))
        roomIconImageView.addGestureRecognizer(roomIconImageViewRecognizer)
    }

    // MARK: - Private Methods
    private func setGroupIconImage() {
        guard let chatRoom = chatRoom else { return }
        roomIconImageView.kf.setImage(with: URL(string: chatRoom.imageURL ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let value):
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                case .failure(_):
                    let firstCharacterOfTheChatRoomName = chatRoom.name?.first ?? String.Element("")
                    if let icon = UIImage(systemName: "\(firstCharacterOfTheChatRoomName).circle") {
                        self.roomIconImageView.image = icon
                    } else {
                        self.roomIconImageView.image = UIImage(systemName: "questionmark.circle")
                    }
            }
        })
    }

    private func setLabelTexts() {
        guard let chatRoom = chatRoom else { return }

        roomIDLabel.text = chatRoom.id ?? ""
        roomNameLabel.text = chatRoom.name ?? ""

        if chatRoom.password?.isEmpty == true {
            roomPasswordLabel.text = "Not Configured"
            roomPasswordLabel.textColor = UIColor(hexString: "CC3300")
        } else {
            self.roomPassword = chatRoom.password ?? ""
            roomPasswordLabel.text = self.roomPassword.replaceCharactersWithAsterisk()
            roomPasswordLabel.textColor = UIColor(hexString: "9D9393")
        }
    }

    private func fetchAndObserverGroupImage() {
        guard let chatRoom = chatRoom else { return }
        let viewModel = RoomSettingsViewModel(chatRoom: chatRoom)
        viewModel.fetchImage {[weak self] imageURL in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setGroupIconImage()
            }
        }
    }

    private func replaceStringWithAsterisk(string: String) -> String {
        var encoded = ""
        for _ in string {
            encoded.append("*")
        }
        return encoded
    }

    // MARK: - Actions
    @objc func deleteRoomButtonAction() {
        AlertHelper.alertMessage(viewController: self, title: "Delete This Room", message: "Do you want to delete this room and everything related to this room in our servers? This action will affect everyone in this room and can NOT be undone.", okButtonText: "Delete") {
            guard let chatRoom = self.chatRoom else { return }
            LottieHUD.shared.show()
            let viewmodel = RoomSettingsViewModel(chatRoom: chatRoom)
            viewmodel.deleteOrBlockRoom {
                LottieHUD.shared.dismiss()
                self.navigationController?.popViewController(animated: true)
                self.delegate?.didDeleteOrBlockRoom()
            }
        }
    }

    @objc func inviteButtonAction() {
        guard let chatRoom = chatRoom else { return }
        guard let chatRoomID = chatRoom.id else { return }
        UIPasteboard.general.string = chatRoomID
        let alertController = UIAlertController(title: "Just Paste It", message: "Room ID Copied to your clipboard.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            //
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func roomIconImageViewRecognizerAction() {
        guard let chatRoom = chatRoom else { return }
        let viewController = RoomImageViewController(chatRoom: chatRoom)
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func membersButtonAction() {
        guard let chatRoom else { return }
        let viewController = RoomMembersViewController(chatRoom: chatRoom)
        self.present(viewController, animated: true)
    }

    @objc func blockRoomAction() {
        AlertHelper.alertMessage(viewController: self, title: "Warning", message: "You will not be able to get new messages from this room and the room will be deleted. Proceed?", okButtonText: "Block") {
            guard let chatRoom = self.chatRoom else { return }
            LottieHUD.shared.show()
            let viewmodel = RoomSettingsViewModel(chatRoom: chatRoom)
            viewmodel.deleteOrBlockRoom {
                LottieHUD.shared.dismiss()
                self.navigationController?.popViewController(animated: true)
                self.delegate?.didDeleteOrBlockRoom()
            }
        }
    }
    
    @objc private func showHideRoomButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            roomPasswordLabel.text = self.roomPassword
        } else {
            roomPasswordLabel.text = self.roomPassword.replaceCharactersWithAsterisk()
        }
    }

    @objc private func changeRoomNameButtonAction() {
        let alertController = UIAlertController(title: "New Room Name!", message: "Please Enter Below:", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Choose something nice..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Enter", style: .default) { action in
            guard let textfields = alertController.textFields else { return }
            var roomName = ""
            if let tempRoomName = textfields[0].text {
                roomName = tempRoomName
            }
            guard let chatRoom = self.chatRoom else { return }
            // Firstly, change the room name inside the collection of chatrooms
            COLLECTION_CHATROOMS.document(chatRoom.id ?? "").getDocument { snapshot, error in
                guard let snapshot else { return }
                // Secondly, change the room name inside the collection of users so the user can see it in the chatRoomListViewController
                snapshot.reference.updateData(["name": roomName])
                COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").collection("chatRooms").document(chatRoom.id ?? "").getDocument { snapshot, error in
                    guard let snapshot else { return }
                    snapshot.reference.updateData(["name": roomName])
                    // Lastly, update the current view and the previous view
                    self.roomNameLabel.text = roomName
                    self.delegate?.didChangeRoomName(with: roomName)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - RoomImageViewController Delegate
extension RoomSettingsViewController: RoomImageViewControllerDelegate {
    func didChangeImage(with image: UIImage) {
        roomIconImageView.image = image
    }
}
