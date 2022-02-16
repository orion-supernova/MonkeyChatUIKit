//
//  ChatRoomViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Foundation
import Firebase

class ChatRoomViewModel {

    private let chatroom: ChatRoom
    var messages = [Message]()

    init(chatroom: ChatRoom) {
        self.chatroom = chatroom
        fetchMessages()
    }

    // MARK: - Fetch Messages
    func fetchMessages() {
        guard let chatroomID = chatroom.id else { return }

            let query = COLLECTION_CHATROOMS.document(chatroomID).collection("chatroom-messages").order(by: "timestamp", descending: false)

            query.addSnapshotListener { snapshot, _ in
                guard let addedDocs = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
                self.messages.append(contentsOf: addedDocs.compactMap({ try? $0.document.data(as: Message.self) }))
            }
        }

    func uploadMessage(message: String) {
        guard let chatroomID = chatroom.id else { return }

        let data = ["message": message,
                    "timestamp": Timestamp(date: Date())] as [String: Any]

        COLLECTION_CHATROOMS.document(chatroomID).collection("chatroom-messages").addDocument(data: data) { error in
            if error != nil {
                AlertHelper.alertMessage(title: "Failed to send message!", message: error?.localizedDescription ?? "", okButtonText: "OK")
                print("Failed to upload message. \(error!.localizedDescription)")
            }
        }
    }
}
