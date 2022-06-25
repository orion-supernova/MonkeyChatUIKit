//
//  ChatRoomListTableViewCell.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

class ChatRoomListTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private lazy var chatRoomIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemPink
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var chatRoomNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Room: Hebele"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()

    private lazy var chatRoomLastMessageSenderNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
    }()

    private lazy var chatRoomLastMessageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Private Properties
    private let chatRoom: ChatRoom? = nil
    private var viewModel: ChatRoomViewModel?
    private var roomSettingsViewModel: RoomSettingsViewModel?

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        chatRoomIconImageView.layer.cornerRadius = chatRoomIconImageView.frame.size.width/2
    }

    // MARK: - Setup
    func setup() {
        contentView.addSubview(chatRoomIconImageView)
        contentView.addSubview(chatRoomNameLabel)
        contentView.addSubview(chatRoomLastMessageSenderNameLabel)
        contentView.addSubview(chatRoomLastMessageLabel)
    }

    func layout() {
        chatRoomIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
        }

        chatRoomNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(chatRoomIconImageView.snp.right).offset(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(20)
        }

        chatRoomLastMessageSenderNameLabel.snp.makeConstraints { make in
            make.top.equalTo(chatRoomNameLabel.snp.bottom).offset(2)
            make.left.equalTo(chatRoomNameLabel.snp.left)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(12)
        }

        chatRoomLastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(chatRoomLastMessageSenderNameLabel.snp.bottom).offset(2)
            make.left.equalTo(chatRoomNameLabel.snp.left)
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)
            make.height.greaterThanOrEqualTo(20)
        }
    }

    // MARK: - Functions
    func configureCell(chatRoom: ChatRoom) {
        if self.viewModel == nil {
            self.viewModel = ChatRoomViewModel(chatroom: chatRoom)
        } else {
            self.viewModel?.chatroom = chatRoom
        }
        guard let viewModel = viewModel else { return }
        self.chatRoomNameLabel.text = chatRoom.name
        let firstCharacterOfTheChatRoomName = chatRoom.name?.first ?? String.Element("")
        if let icon = UIImage(systemName: "\(firstCharacterOfTheChatRoomName).circle") {
            guard chatRoomIconImageView.image != icon else { return }
            chatRoomIconImageView.image = icon
        } else {
            let icon = UIImage(systemName: "questionmark.circle")
            guard chatRoomIconImageView.image != icon else { return }
            chatRoomIconImageView.image = icon
        }
        viewModel.getLastMessage {
            if viewModel.lastMessage?.message == "" || viewModel.lastMessage?.message == nil {
                self.chatRoomLastMessageSenderNameLabel.text = ""
                self.chatRoomLastMessageLabel.text = "No messages here yet"
            } else {
                if let senderName = viewModel.lastMessage?.senderName {
                    if senderName == "" {
                        self.chatRoomLastMessageSenderNameLabel.text = "Anonymous"
                    } else {
                        self.chatRoomLastMessageSenderNameLabel.text = senderName == AppGlobal.shared.username ? "You" : senderName
                    }
                } else {
                    self.chatRoomLastMessageSenderNameLabel.text = "Anonymous"
                }
                self.chatRoomLastMessageLabel.text = viewModel.lastMessage?.message
            }
        }
        if roomSettingsViewModel == nil {
            self.roomSettingsViewModel = RoomSettingsViewModel(chatRoom: chatRoom)
        } else {
            self.roomSettingsViewModel?.chatRoom = chatRoom
        }
        roomSettingsViewModel?.fetchImage { [weak self] imageURL in
            guard let self = self else { return }
                self.setGroupIconImage(url: imageURL)
        }
    }

    // MARK: - Private Methods
    private func setGroupIconImage(url: String) {
        guard url.isEmpty == false else { return }
        chatRoomIconImageView.kf.setImage(with: URL(string: url), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { result in
            switch result {
                case .success(let value):
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        })
    }
}
