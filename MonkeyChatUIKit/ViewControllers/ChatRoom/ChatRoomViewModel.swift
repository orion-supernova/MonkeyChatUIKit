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

final class ChatRoomViewModel {

    // MARK: - Stored Properties
    var chatroom: ChatRoom
    var messages = [Message]()
    var lastMessage: Message?
    weak var delegate: ChatRoomViewModelDelegate?
    var selectedMessage: Message?

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
        guard let chatRoomName = chatroom.name else { return }

        let data = ["senderName": AppGlobal.shared.username ?? "",
                    "senderUID": AppGlobal.shared.userID ?? "",
                    "message": message,
                    "chatRoomID": chatroomID,
                    "timestamp": Timestamp(date: Date())] as [String: Any]

        let room = COLLECTION_CHATROOMS.document(chatroomID)
        room.collection("chatroom-messages").addDocument(data: data) { [weak self] error in
            if error != nil {
                AlertHelper.alertMessage(title: "Failed to send message!", message: error?.localizedDescription ?? "", okButtonText: "OK")
                print("Failed to upload message. \(error!.localizedDescription)")
            }
            let lastMessageData = ["lastMessageTimestamp": Timestamp(date: Date())] as [String: Any]
            room.updateData(lastMessageData) { error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }

                room.collection("userIDs").getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    var fcmTokenForThisChatRoom = [String]()
                    documents.forEach({ fcmTokenForThisChatRoom.append($0.get("fcmToken") as? String ?? "")})
                    fcmTokenForThisChatRoom.forEach({ sender.sendPushNotification(to: $0, title: "\(self?.chatroom.name ?? "")", body: "\(message)", chatRoomID: chatroomID, chatRoomName: chatRoomName, category: .messageCategory) })
                }
            }
        }
    }

    func reportMessage() {
        guard let selectedMessage else { return }
        let data = ["message": selectedMessage.message,
                    "senderUID": selectedMessage.senderUID ?? "",
                    "senderName": selectedMessage.senderName ?? "",
                    "chatRoomID":selectedMessage.chatRoomID ?? "",
                    "reportedMessageID": selectedMessage.id ?? "",
                    "reportedMessageTimestamp": selectedMessage.timestamp ,
                    "reportTime": Date()] as [String: Any]
        COLLECTION_REPORTS.addDocument(data: data) { [weak self] error in
            guard let self = self else { return }
            guard error == nil else { self.gotError(error: error); return }
            print("DEBUG: --- Reported Message is \(selectedMessage)")
        }
    }

    func removeUserFromChatRoom() {
        guard let selectedMessage else { return }
        guard let senderUID = selectedMessage.senderUID else { return }
        guard let chatRoomID = selectedMessage.chatRoomID else { return }
        COLLECTION_USERS.document(senderUID).collection("chatRooms").document(chatRoomID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot, error == nil else { self.gotError(error: error); return }
            snapshot.reference.delete { error in
                guard error == nil else {
                    self.gotError(error: error)
                    return
                }
                COLLECTION_CHATROOMS.document(chatRoomID).collection("userIDs").document(senderUID).getDocument { snapshot, error in
                    guard let snapshot, error == nil else { self.gotError(error: error); return }
                    snapshot.reference.delete { error in
                        guard error == nil else { self.gotError(error: error); return }
                        print("DEBUG: --- Removed user is \(selectedMessage.senderName ?? "Anonymous") with id \(senderUID)")
                    }
                }
            }
        }
    }

    private func gotError(error: Error?) {
        AlertHelper.alertMessage(title: "Error", message: error?.localizedDescription ?? "Something went wrong.", okButtonText: "OK")
    }
}
