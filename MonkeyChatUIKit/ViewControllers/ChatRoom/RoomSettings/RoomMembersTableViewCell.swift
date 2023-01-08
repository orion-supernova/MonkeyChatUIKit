//
//  RoomMembersTableViewCell.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 10.11.2022.
//

import UIKit
import SnapKit

class RoomMembersTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        return label
    }()

    // MARK: - Private Properties
    private let chatRoom: ChatRoom? = nil

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
        contentView.addSubview(usernameLabel)
    }

    func layout() {
        usernameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Functions
    func configureCell(username: String) {
        usernameLabel.text = username
    }
}



