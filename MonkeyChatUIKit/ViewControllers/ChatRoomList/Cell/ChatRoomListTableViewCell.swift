//
//  ChatRoomListTableViewCell.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class ChatRoomListTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private let chatRoomNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Room: Hebele"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()

    private let chatRoomLastMessageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13, weight: .regular)
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
        contentView.addSubview(chatRoomLastMessageLabel)
    }

    func layout() {
        chatRoomNameLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(10)
            make.height.greaterThanOrEqualTo(20)
        }
        chatRoomLastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(chatRoomNameLabel.snp.bottom).offset(2)
            make.left.equalTo(10)
            make.height.greaterThanOrEqualTo(15)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Functions
    func configureCell(chatRoom: ChatRoom) {
        let viewmodel = ChatRoomViewModel(chatroom: chatRoom)
        self.chatRoomNameLabel.text = chatRoom.name
        viewmodel.getLastMessage {
            self.chatRoomLastMessageLabel.text = viewmodel.lastMessage?.message
        }
    }
}
