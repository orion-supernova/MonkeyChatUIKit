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
        COLLECTION_CHATROOMS.order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let documents = snapshot?.documents else { return }

            self.chatRooms = documents.compactMap({ try? $0.data(as: ChatRoom.self)  })
            print("ChatRooms fetched successfully")
            completion()
        }
    }

    // MARK: - Create Or Enter Room Action
    func createRoomOrEnterRoomAction(completion: @escaping (String?) -> Void) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let enterRoomAction = UIAlertAction(title: "Enter Room", style: .default) { [weak self] action in
            self?.enterRoom { roomCode in
                completion(roomCode)
            }
        }
        let createRoomAction = UIAlertAction(title: "Create Room", style: .default) { [weak self] action in
            self?.createRoom()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(enterRoomAction)
        actionSheetController.addAction(createRoomAction)
        actionSheetController.addAction(cancelAction)

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(actionSheetController, animated: true, completion: nil)
    }

    // MARK: - Enter Room Action
    func enterRoom(completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Enter Room", message: "Please enter the room name:", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Room Name"
            textfield.keyboardType = .numberPad
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Enter", style: .default) { action in
            guard let textfields = alertController.textFields else { return }
            var code = ""
            if let roomCode = textfields[0].text {
                code = roomCode
            }
            completion(code)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Create Room Action
    func createRoom() {
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
            let data = ["name": name,
                        "password": password,
                        "timestamp": Timestamp(date: Date())] as [String: Any]

            COLLECTION_CHATROOMS.addDocument(data: data) { error in
                guard error == nil else { return }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertController, animated: true, completion: nil)
    }

    func removeListeners() {
//        COLLECTION_CHATROOMS.order(by: "timestamp", descending: true).remo
//        }
    }
}
