//
//  ChatRoomsViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ChatRoomListViewModel {
    typealias AlertCompletion = ((Bool) -> Void)?

    var chatRooms = [ChatRoom]()
    static var lastMessageInChatRoom: Message?

    func fetchChatRooms(completion: @escaping () -> Void) {
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).collection("chatRooms").order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let documents = snapshot?.documents else { return }

            self.chatRooms = documents.compactMap({ try? $0.data(as: ChatRoom.self)  })
            print("ChatRooms fetched successfully")
            completion()
        }
    }

    // MARK: - Create Or Enter Room Action
    func createRoomOrEnterRoomAction(target: UIViewController) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let enterRoomAction = UIAlertAction(title: "Enter Room", style: .default) { [weak self] action in
            self?.enterRoom()
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
    func enterRoom() {
        let alertController = UIAlertController(title: "Enter Room", message: "Please enter the room name:", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Room Name"
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
            COLLECTION_CHATROOMS.getDocuments { snapshot, error in
                guard error == nil else { return }
                guard let documents = snapshot?.documents else { return }
                var foundRoomDict: [String: Any]?
                for document in documents {
                    if document.documentID == roomID {
                        foundRoomDict = document.data()
                    }
                }
                guard let foundRoom = foundRoomDict else { return }
                if roomID == "" {
                    AlertHelper.alertMessage(title: "ERROR", message: "Inlavid Room Code", okButtonText: "OK")
                    return
                }
                guard let foundRoomID = foundRoom["roomID"] as? String else { return }
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

                        COLLECTION_USERS.document(userID).collection("chatRooms").document(roomID).setData(data) { [weak self] error in
                            guard error == nil else { return }
                            guard let self = self else { return }
                            self.fetchChatRooms {
                                print("DEBUG: ENTERED ROOM \(foundRoomID)")
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

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertController, animated: true, completion: nil)
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
            let data = ["name": name,
                        "password": password,
                        "timestamp": Timestamp(date: Date()),
                        "roomID": roomID] as [String: Any]

            COLLECTION_CHATROOMS.document(roomID).setData(data) { error in

                guard error == nil else { return }

                guard let userID = AppGlobal.shared.userID else { return }
                guard let fcmToken = AppGlobal.shared.fcmToken else { return }

                let userDataWithFcmToken = ["userID": userID,
                                            "fcmToken": fcmToken] as [String: Any]
                COLLECTION_CHATROOMS.document(roomID).collection("userIDs").document(userID).setData(userDataWithFcmToken) { error in
                    guard error == nil else { return }
                    let chatRoomdataInUserList = data
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
