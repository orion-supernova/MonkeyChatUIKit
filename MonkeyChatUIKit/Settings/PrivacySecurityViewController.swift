//
//  PrivacySecurityViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 2.05.2022.
//

import UIKit
import SnapKit

class PrivacySecurityViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeleteMyAccount")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setup()
        layout()
        setDelegates()
    }

    // MARK: - Setup & Layout
    private func setup() {
        view.addSubview(tableView)
    }

    private func layout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Private Methods
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func removeUserAndLogout() {
        AuthManager.shared.deleteUser { error in
            LottieHUD.shared.dismiss()
            guard error == nil else {
                AlertHelper.alertMessage(title: "Couldn't Delete Account", message: error?.localizedDescription ?? "Something went wrong. Please try again.", okButtonText: "OK")
                return
            }
            DispatchQueue.main.async {
                let viewController = AuthViewController()
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITableView Delegate
extension PrivacySecurityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            AlertHelper.alertMessage(viewController: self, title: "Delete My Account", message: "We are sorry to hear that you want to delete your account. If  you proceed, your account will be deleted and you will be removed from all the rooms you're currently in. But your messages will not be affected. Remember that this action can NOT be undone.") {
                LottieHUD.shared.show()
                let group = DispatchGroup()
                    var chatRoomsArray = [String]()
                COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").collection("chatRooms").getDocuments { [weak self] chatRoomSnapshot, error in
                    guard let self = self else { return }
                    guard let chatRoomSnapshot = chatRoomSnapshot else { return }
                    let documents = chatRoomSnapshot.documents
                    if documents.isEmpty {
                        self.removeUserAndLogout()
                    }
                    for document in documents {
                        chatRoomsArray.append(document.documentID)
                    }
                    group.enter()
                    for roomID in chatRoomsArray {
                        let room = COLLECTION_CHATROOMS.document(roomID)
                        room.collection("userIDs").document(AppGlobal.shared.userID ?? "").delete()
                        room.collection("userIDs").getDocuments(completion: { snapshot, error in
                            guard let snapshot = snapshot else { return }
                            if snapshot.documents.isEmpty {
                                room.delete()
                            }
                            group.leave()
                        })
                    }
                    group.notify(queue: .global()) {
                        COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").collection("chatRooms").getDocuments { snapshot, error in
                            guard let snapshot = snapshot else { return }
                            snapshot.documents.forEach({ $0.reference.delete() })

                            COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").delete { error in
                                guard error == nil else { return }
                                self.removeUserAndLogout()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UITableView DataSource
extension PrivacySecurityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteMyAccount", for: indexPath)
            cell.textLabel?.text = "Delete My Account"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
