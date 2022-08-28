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
}

class RoomSettingsViewController: UIViewController {
    // MARK: - Elements
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

    private lazy var roomIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var roomNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var roomPasswordLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
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

    // MARK: - Public Properties
    var chatRoom: ChatRoom?
    var navigationBarHeight: CGFloat = 0
    var tabbarHeight: CGFloat = 0
    weak var delegate: RoomSettingsViewControllerDelegate?

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        configureNavigationBar()
        addGestures()
        fetchAndObserverGroupImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roomIconImageView.layer.cornerRadius = 50 // size'ın yarısı kadar olmalı ki daire olsun
        roomIconImageView.clipsToBounds = true
        inviteButton.layer.cornerRadius = 5
        blockButton.layer.cornerRadius = 5
    }

    // MARK: - Seyup & Layout
    private func setup() {
        view.addSubview(mainContainerView)
        mainContainerView.addSubview(roomIconImageView)
        mainContainerView.addSubview(roomIDLabel)
        mainContainerView.addSubview(roomNameLabel)
        mainContainerView.addSubview(roomPasswordLabel)
        mainContainerView.addSubview(seperatorOneView)
        mainContainerView.addSubview(inviteButton)
        mainContainerView.addSubview(blockButton)
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

        roomIDLabel.snp.makeConstraints { make in
            make.top.equalTo(roomIconImageView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }

        roomNameLabel.snp.makeConstraints { make in
            make.top.equalTo(roomIDLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }

        roomPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(roomNameLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
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

        let boldAttributes: [NSAttributedString.Key : Any] = [ .font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor(named: "Black-White") ?? .secondaryLabel]
        let regularAttributes: [NSAttributedString.Key : Any] = [ .font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor(hexString: "9D9393")]
        let redAttributes: [NSAttributedString.Key : Any] = [ .font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor(hexString: "CC3300")]

        let roomIDAttributedString = NSMutableAttributedString()
        roomIDAttributedString.append(NSAttributedString(string: "Room ID:\n", attributes: boldAttributes))
        roomIDAttributedString.append(NSAttributedString(string: "\(chatRoom.id ?? "")", attributes: regularAttributes))
        roomIDLabel.attributedText = roomIDAttributedString

        let roomNameAttributedString = NSMutableAttributedString()
        roomNameAttributedString.append(NSAttributedString(string: "Room Name:\n", attributes: boldAttributes))
        roomNameAttributedString.append(NSAttributedString(string: "\(chatRoom.name ?? "")", attributes: regularAttributes))
        roomNameLabel.attributedText = roomNameAttributedString

        let roomPasswordAttributedString = NSMutableAttributedString()
        roomPasswordAttributedString.append(NSAttributedString(string: "Room Password:\n", attributes: boldAttributes))
        if chatRoom.password?.isEmpty == true {
            roomPasswordAttributedString.append(NSAttributedString(string: "Not Configured", attributes: redAttributes))
        } else {
            roomPasswordAttributedString.append(NSAttributedString(string: "\(chatRoom.password ?? "")", attributes: regularAttributes))
        }
        roomPasswordLabel.attributedText = roomPasswordAttributedString
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
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
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
}

extension RoomSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true)
        guard let image = image else { return }
        LottieHUD.shared.show()
        guard let chatRoom = chatRoom else { return }
        let viewModel = RoomSettingsViewModel(chatRoom: chatRoom)
        viewModel.uploadPicture(image: image) { [weak self] in
            guard let self = self else { return }
            self.roomIconImageView.image = image
            LottieHUD.shared.dismiss()
        }
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
