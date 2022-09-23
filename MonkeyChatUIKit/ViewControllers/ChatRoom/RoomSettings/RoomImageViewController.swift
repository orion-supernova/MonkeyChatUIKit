//
//  RoomImageViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 23.09.2022.
//

import UIKit
import SnapKit
import Kingfisher
import Zoomy

protocol RoomImageViewControllerDelegate: AnyObject {
    func didChangeImage(with image: UIImage)
}

class RoomImageViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        button.tintColor = .systemPink
        return button
    }()

    // MARK: - Private Properties
    private var chatRoom: ChatRoom?

    // MARK: - Public Properties
    weak var delegate: RoomImageViewControllerDelegate?

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        setRoomImage()
        addZoombehavior(for: imageView, settings: .defaultSettings)
    }

    // MARK: - Setup & Layout
    private func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(editButton)
    }

    private func layout() {
        let width = view.frame.width

        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(width)
        }

        editButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.bottom.equalTo(imageView.snp.top).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(95)
        }
    }

    // MARK: - Private Methods
    private func setRoomImage() {
        guard let chatRoom = chatRoom else { return }
        imageView.kf.setImage(with: URL(string: chatRoom.imageURL ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let value):
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                case .failure(_):
                    let firstCharacterOfTheChatRoomName = chatRoom.name?.first ?? String.Element("")
                    if let icon = UIImage(systemName: "\(firstCharacterOfTheChatRoomName).circle") {
                        self.imageView.image = icon
                    } else {
                        self.imageView.image = UIImage(systemName: "questionmark.circle")
                    }
            }
        })
    }

    // MARK: - Actions
    @objc private func editButtonAction() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
}

// MARK: - ImagePicker Delegate
extension RoomImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true)
        guard let image = image else { return }
        LottieHUD.shared.show()
        guard let chatRoom = chatRoom else { return }
        let viewModel = RoomSettingsViewModel(chatRoom: chatRoom)
        viewModel.uploadPicture(image: image) { [weak self] in
            guard let self = self else { return }
            self.imageView.image = image
            LottieHUD.shared.dismiss()
            self.delegate?.didChangeImage(with: image)
        }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
