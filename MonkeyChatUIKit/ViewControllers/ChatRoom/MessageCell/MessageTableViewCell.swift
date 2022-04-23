//
//  MessageTableViewCell.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

class MessageTableViewCell: UITableViewCell {

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "message"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()


    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setup & Layout
    func setup() {
        contentView.addSubview(usernameLabel)
        contentView.addSubview(messageLabel)
    }

    func layout() {
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.equalTo(15)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)
        }
    }

    // MARK: - Functions
    func configureCell(message: Message) {
        if message.senderName == "" || message.senderName == nil{
            usernameLabel.text = "Anonymous"
        } else {
            usernameLabel.text = message.senderName
        }
        self.messageLabel.text = message.message
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
