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
    private let chatRoomNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Room: Hebele"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let chatRoomLastMessageSenderNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let chatRoomLastMessageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Private Properties
    let chatRoom: ChatRoom? = nil

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    func setup() {
        contentView.addSubview(chatRoomNameLabel)
        contentView.addSubview(chatRoomLastMessageSenderNameLabel)
        contentView.addSubview(chatRoomLastMessageLabel)
    }

    func layout() {
        chatRoomNameLabel.snp.makeConstraints { make in
            make.top.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(20)
        }

        chatRoomLastMessageSenderNameLabel.snp.makeConstraints { make in
            make.top.equalTo(chatRoomNameLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(12)
        }

        chatRoomLastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(chatRoomLastMessageSenderNameLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)
            make.height.greaterThanOrEqualTo(20)
        }
    }

    // MARK: - Functions
    func configureCell(chatRoom: ChatRoom) {
        let viewmodel = ChatRoomViewModel(chatroom: chatRoom)
        self.chatRoomNameLabel.text = chatRoom.name
        viewmodel.getLastMessage {
            if viewmodel.lastMessage?.message == "" || viewmodel.lastMessage?.message == nil {
                self.chatRoomLastMessageSenderNameLabel.text = ""
                self.chatRoomLastMessageLabel.text = "No messages here yet"
            } else {
                if let senderName = viewmodel.lastMessage?.senderName {
                    if senderName == "" {
                        self.chatRoomLastMessageSenderNameLabel.text = "Anonymous"
                    } else {
                        self.chatRoomLastMessageSenderNameLabel.text = senderName == AppGlobal.shared.username ? "You" : senderName
                    }
                } else {
                    self.chatRoomLastMessageSenderNameLabel.text = "Anonymous"
                }
                self.chatRoomLastMessageLabel.text = viewmodel.lastMessage?.message
            }
        }
    }
}
