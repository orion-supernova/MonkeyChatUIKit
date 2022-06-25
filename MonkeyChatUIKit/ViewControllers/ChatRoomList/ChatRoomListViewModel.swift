//
//  ChatRoomsViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

protocol ChatRoomListViewModelDelegate: AnyObject {
    func didChangeDataSource()
}

class ChatRoomListViewModel {
    typealias AlertCompletion = ((Bool) -> Void)?

    // MARK: - Public Properties
    var chatRooms = [ChatRoom]()
    weak var delegate: ChatRoomListViewModelDelegate?

    func fetchChatRooms() {
        guard let userID = AppGlobal.shared.userID else { return }

        COLLECTION_USERS.document(userID).collection("chatRooms").addSnapshotListener {[weak self] snapshot, error in
            guard let self = self else { return }
            var count = 0
            var chatRoomDocuments = [DocumentSnapshot]()
            self.chatRooms.removeAll()
            guard error == nil else { print(error!.localizedDescription); return }
            guard let documents = snapshot?.documents else { return }
            self.chatRooms = documents.compactMap({ try? $0.data(as: ChatRoom.self) })

            let group = DispatchGroup()
            for room in self.chatRooms {
                group.enter()
                COLLECTION_CHATROOMS.document(room.id ?? "").addSnapshotListener { snapshot, error in
                    guard error == nil else { print(error!.localizedDescription); return }
                    guard let document = snapshot else { return }
                    if count == 0 {
                        chatRoomDocuments.append(document)
                        group.leave()
                    } else {
                        let room = chatRoomDocuments.first(where: { $0.documentID == room.id })
                        chatRoomDocuments.removeAll(where: { $0 == room})
                        chatRoomDocuments.append(document)
                        orderRooms()
                    }
                }
            }
            group.notify(queue: .global()) {
                count += 1
                orderRooms()
            }
            func orderRooms() {
                self.chatRooms.removeAll()
                self.chatRooms = chatRoomDocuments.compactMap({ try? $0.data(as: ChatRoom.self) })
                self.chatRooms.sort(by: { (first: ChatRoom, second: ChatRoom) -> Bool in
                    first.lastMessageTimestamp?.seconds ?? 0 > second.lastMessageTimestamp?.seconds ?? 0
                })
                self.delegate?.didChangeDataSource()
            }
        }
    }

    // MARK: - Create Or Enter Room Action
    func createRoomOrEnterRoomAction(target: UIViewController) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let enterRoomAction = UIAlertAction(title: "Enter Room", style: .default) { [weak self] action in
            self?.enterRoom(target: target)
        }
        let createRoomAction = UIAlertAction(title: "Create Room", style: .default) { [weak self] action in
            self?.createRoom(target: target)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(enterRoomAction)
        actionSheetController.addAction(createRoomAction)
        actionSheetController.addAction(cancelAction)

        target.present(actionSheetController, animated: true, completion: nil)
    }

    // MARK: - Enter Room Action
    func enterRoom(target: UIViewController) {
        let alertController = UIAlertController(title: "Enter Room", message: "Please enter the room Code:", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Room Code"
        }
        alertController.addTextField { textfield in
            textfield.placeholder = "Room Password"
            textfield.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Enter", style: .default) { action in
            guard let textfields = alertController.textFields else { return }
            var roomID = ""
            var roomPassword = ""
            if let tempRoomID = textfields[0].text {
                roomID = tempRoomID
            }
            if let tempPassword = textfields[1].text {
                roomPassword = tempPassword
            }
            guard let userID = AppGlobal.shared.userID else { return }
            COLLECTION_CHATROOMS.document(roomID).getDocument { snapshot, error in
                guard error == nil else {
                    AlertHelper.alertMessage(title: "ERROR",
                                             message: error?.localizedDescription ?? "",
                                             okButtonText: "OK")
                    return
                }
                let foundRoomDict = snapshot?.data()
                guard let foundRoom = foundRoomDict else {
                    AlertHelper.alertMessage(title: "ERROR",
                                             message: "The room you're trying to enter is not exist. Please check your ID.",
                                             okButtonText: "OK")
                    return
                }
                guard let fcmToken = AppGlobal.shared.fcmToken else { return }

                let userDataWithFcmToken = ["userID": userID,
                                            "fcmToken": fcmToken] as [String: Any]

                if roomPassword == foundRoom["password"] as? String {
                    COLLECTION_CHATROOMS.document(roomID).collection("userIDs").document(userID).setData(userDataWithFcmToken) { error in
                        guard error == nil else { return }

                        let data = ["name": foundRoom["name"] ?? "",
                                    "password": foundRoom["password"] ?? "",
                                    "timestamp": Timestamp(date: Date()),
                                    "roomID": roomID] as [String: Any]

                        COLLECTION_USERS.document(userID).collection("chatRooms").document(roomID).setData(data) { error in
                            guard error == nil else {
                                print(error?.localizedDescription ?? "")
                                return
                            }
                        }
                    }
                } else {
                    AlertHelper.alertMessage(title: "ERROR", message: "Invalid Room Password", okButtonText: "OK")
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)


        target.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Create Room Action
    func createRoom(target: UIViewController) {
        let alertController = UIAlertController(title: "This will be your Chat Room", message: "Please configure as you like.", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Booth name"
        }
        alertController.addTextField { textfield in
            textfield.placeholder = "Secure Password (Optional)"
            textfield.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Create my room!", style: .default) { (action: UIAlertAction) in
            guard let textFields = alertController.textFields else { return }
            var name = ""
            var password = ""
            if let boothName = textFields[0].text {
                name = boothName
            }
            if let boothPassword = textFields[1].text {
                password = boothPassword
            }
            let roomID = UUID().uuidString
            let dataForChatRoom = ["name": name,
                        "password": password,
                        "timestamp": Timestamp(date: Date()),
                        "roomID": roomID,
                        "lastMessageTimestamp": Timestamp(date: Date())] as [String: Any]

            COLLECTION_CHATROOMS.document(roomID).setData(dataForChatRoom) { error in

                guard error == nil else { return }

                guard let userID = AppGlobal.shared.userID else { return }
                guard let fcmToken = AppGlobal.shared.fcmToken else { return }

                let userDataWithFcmToken = ["userID": userID,
                                            "fcmToken": fcmToken] as [String: Any]
                COLLECTION_CHATROOMS.document(roomID).collection("userIDs").document(userID).setData(userDataWithFcmToken) { error in
                    guard error == nil else { return }
                    let chatRoomdataInUserList = ["name": name,
                                                  "password": password,
                                                  "timestamp": Timestamp(date: Date()),
                                                  "roomID": roomID] as [String: Any]
                    COLLECTION_USERS.document(userID).collection("chatRooms").document(roomID).setData(chatRoomdataInUserList) { error in
                        guard error == nil else { return }
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        target.present(alertController, animated: true, completion: nil)
    }

    func removeListeners() {
//        COLLECTION_CHATROOMS.order(by: "timestamp", descending: true).remo
//        }
    }
}
