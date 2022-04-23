//
//  ChatRoomViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Foundation
import Firebase

protocol ChatRoomViewModelDelegate: AnyObject {
    func didChangeDataSource()
}

class ChatRoomViewModel {

    // MARK: - Stored Properties
    private let chatroom: ChatRoom
    var messages = [Message]()
    var lastMessage: Message?
    weak var delegate: ChatRoomViewModelDelegate?

    // MARK: - Lifecycle
    init(chatroom: ChatRoom) {
        self.chatroom = chatroom
    }

    // MARK: - Functions
    func fetchMessages(completion: @escaping(() -> Void)) {
        guard let chatroomID = chatroom.id else { return }

        COLLECTION_CHATROOMS.document(chatroomID).collection("chatroom-messages").order(by: "timestamp", descending: false).addSnapshotListener {[weak self] snapshot, error in
            guard let self = self else { return }
            guard error == nil else { print(error!.localizedDescription); return }
            guard let addedDocs = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            self.messages.append(contentsOf: addedDocs.compactMap({ try? $0.document.data(as: Message.self)}))
            self.lastMessage = self.messages.last
            self.delegate?.didChangeDataSource()
            completion()

        }
    }

    func getLastMessage(completion: @escaping(() -> Void)) {
        guard let chatroomID = chatroom.id else { return }
        COLLECTION_CHATROOMS.document(chatroomID).collection("chatroom-messages").order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let addedDocs = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            self.lastMessage = addedDocs.compactMap({ try? $0.document.data(as: Message.self) }).last
            completion()
        }
    }

    func uploadMessage(message: String) {
        let sender = PushNotificationSender()
        guard let chatroomID = chatroom.id else { return }

        let data = ["senderName": AppGlobal.shared.username ?? "",
                    "message": message,
                    "timestamp": Timestamp(date: Date())] as [String: Any]

        COLLECTION_CHATROOMS.document(chatroomID).collection("chatroom-messages").addDocument(data: data) { [weak self] error in
            if error != nil {
                AlertHelper.alertMessage(title: "Failed to send message!", message: error?.localizedDescription ?? "", okButtonText: "OK")
                print("Failed to upload message. \(error!.localizedDescription)")
            }
            COLLECTION_CHATROOMS.document(chatroomID).collection("userIDs").getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                var fcmTokenForThisChatRoom = [String]()
                for document in documents {
                    fcmTokenForThisChatRoom.append(document.get("fcmToken") as? String ?? "")
                }
                for token in fcmTokenForThisChatRoom {
                    sender.sendPushNotification(to: token, title: "\(self?.chatroom.name ?? "")", body: "\(message)")
                }
            }
        }
    }
}
