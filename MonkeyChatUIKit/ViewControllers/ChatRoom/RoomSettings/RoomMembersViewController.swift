//
//  RoomMembersViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 10.11.2022.
//

import UIKit
import SnapKit

class RoomMembersViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var membersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Members"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoomMembersTableViewCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - Private Properties
    private var chatRoom: ChatRoom?
    private var usernames = [String]()

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
        getMembers()
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .darkGray
        view.addSubview(membersTitleLabel)
        view.addSubview(tableView)
    }

    // MARK: - Layout
    private func layout() {
        membersTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(membersTitleLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - Private Methods
    private func getMembers() {
        COLLECTION_CHATROOMS.document(chatRoom?.id ?? "").collection("userIDs").getDocuments { snapshot, error in
            guard let snapshot else { return }
            for document in snapshot.documents {
                let dict = document.data()
                let userID = dict["userID"] as? String ?? ""
                COLLECTION_USERS.document(userID).getDocument { snapshot, error in
                    guard error == nil else { return }
                    guard let snapshot = snapshot else { return }
                    let dict = snapshot.data()
                    var username = dict?["username"] as? String ?? "unknown"
                    username == "" ? username = "anonymous, id -> \(userID)" : (username = "\(username), id -> \(userID)")
                    self.usernames.append(username)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableView Delegate
extension RoomMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableView DataSource
extension RoomMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomMembersTableViewCell", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
