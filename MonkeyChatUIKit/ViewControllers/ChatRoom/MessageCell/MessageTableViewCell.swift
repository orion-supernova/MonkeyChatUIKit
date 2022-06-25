//
//  MessageTableViewCell.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

class MessageTableViewCell: UITableViewCell {

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var messageBubble: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "message"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private lazy var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "date"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 8, weight: .regular)
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

    override func layoutSubviews() {
        messageBubble.layer.cornerRadius = 10
    }

    //MARK: - Setup & Layout
    func setup() {
        contentView.addSubview(usernameLabel)
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageLabel)
        messageBubble.addSubview(messageTimeLabel)
    }

    func layout() {
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.equalTo(15)
        }
    }

    // MARK: - Public Methods
    func configureCell(message: Message) {
        if message.senderName == "" || message.senderName == nil{
            usernameLabel.text = "Anonymous"
        } else {
            usernameLabel.text = message.senderName
        }

        messageTimeLabel.text = message.timestampString

        if message.senderUID?.isEmpty == true {
            configureLeftBubble()
            self.messageLabel.text = message.message
        } else {
            if message.senderUID == AppGlobal.shared.userID {
                configureRightBubble()
                self.messageLabel.text = message.message
            } else {
                configureLeftBubble()
                self.messageLabel.text = message.message
            }
        }
    }

    // MARK: - Private Methods
    private func configureLeftBubble() {
        usernameLabel.textAlignment = .left
        messageLabel.textColor = UIColor(named: "Black-White")
        messageBubble.backgroundColor = .secondarySystemFill

        messageBubble.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
            make.right.equalTo(messageTimeLabel.snp.right).offset(5)
            make.bottom.equalTo(-5)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.8)
            make.bottom.equalTo(-5)
        }

        messageTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-5)
            make.left.equalTo(messageLabel.snp.right).offset(5)
            make.height.lessThanOrEqualTo(30)
            make.width.lessThanOrEqualTo(30)
        }
    }

    private func configureRightBubble() {
        usernameLabel.textAlignment = .right
        messageBubble.backgroundColor = .monkeyBlue
        messageLabel.textColor = .white

        messageBubble.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.right.equalTo(-5)
            make.left.equalTo(messageLabel.snp.left).offset(-5)
            make.bottom.equalTo(-5)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(messageTimeLabel.snp.left).offset(-3)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.8)
            make.bottom.equalTo(-5)
        }

        messageTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-5)
            make.right.equalTo(-5)
            make.height.lessThanOrEqualTo(30)
            make.width.lessThanOrEqualTo(30)
        }
    }

    private func estimatedWidthForText() {

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        messageLabel.text = ""
        messageLabel.snp.removeConstraints()
        messageBubble.snp.removeConstraints()
        messageTimeLabel.snp.removeConstraints()
    }
}
