//
//  RoomSettingsViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 20.06.2022.
//

import UIKit
import Firebase

class RoomSettingsViewModel {

    // MARK: - Public Properties
    var chatRoom: ChatRoom?

    // MARK: - Lifecycle
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }

    // MARK: - Functions
    func fetchImage(completion: @escaping (String) -> Void) {
        guard let chatRoomID = chatRoom?.id else { return }

        COLLECTION_CHATROOMS.document(chatRoomID).getDocument { snapshot, error in
            guard error == nil else { return }
            guard let snapshot = snapshot else { return }

            let dict = snapshot.data()
            let imageURL = dict?["imageURL"] as? String
            completion(imageURL ?? "")
        }
    }

    func uploadPicture(image: UIImage, completion: @escaping(() -> Void)) {
        guard let chatRoomID = self.chatRoom?.id else { return }
        let room = COLLECTION_CHATROOMS.document(chatRoomID)
        room.getDocument { snapshot, error in
            guard error == nil, snapshot != nil else { return }
            let dict = snapshot?.data()
            let imageURL = dict?["imageURL"] as? String
            if imageURL?.isEmpty == false {
                self.deletePreviousImageFromStorage()
            }
            ImageUploader.uploadImage(image: image, type: .chatRoomPicture) { imageURL in
                let imageURLData = ["imageURL": imageURL] as [String: Any]
                room.updateData(imageURLData) { error in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "")
                        return
                    }
                    completion()
                }
            }
        }
    }

    func deletePreviousImageFromStorage() {
        let storage = Storage.storage()
        storage.reference(forURL: chatRoom?.imageURL ?? "").delete { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }

    func deleteOrBlockRoom(completion: @escaping () -> Void) {
        // Find everyone in this room
        COLLECTION_CHATROOMS.document(chatRoom?.id ?? "").collection("userIDs").getDocuments { snapshot, error in
            guard error == nil, let snapshot = snapshot else { return }
            var userIDs = [String]()
            let documents = snapshot.documents
            for document in documents {
                let dict = document.data()
                let id = dict["userID"] as? String
                userIDs.append(id ?? "")
            }
            // Delete room from Rooms
            COLLECTION_CHATROOMS.document(self.chatRoom?.id ?? "").getDocument { snapshot, error in
                guard error == nil else { return }
                guard let snapshot = snapshot else { return }
                snapshot.reference.delete { error in
                    guard error == nil else { return }
                }
                // Go into every user in the room delete the room from rooms
                for userID in userIDs {
                    COLLECTION_USERS.document(userID).collection("chatRooms").document(self.chatRoom?.id ?? "").getDocument { snapshot, error in
                        guard let snapshot = snapshot, error == nil else { return }
                        snapshot.reference.delete { error in
                            guard error == nil else { return }
                        }
                    }
                }
                completion()
            }
        }
    }
}
