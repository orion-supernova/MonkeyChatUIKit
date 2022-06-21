//
//  RoomSettingsViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 20.06.2022.
//

import UIKit
import Firebase

class RoomSettingsViewModel {

    // MARK: - Private Properties
    private var chatRoom: ChatRoom?

    // MARK: - Lifecycle
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }

    // MARK: - Functions
    func fetchImage(completion: @escaping (String) -> Void) {
        guard let chatRoomID = chatRoom?.id else { return }

        COLLECTION_CHATROOMS.document(chatRoomID).addSnapshotListener { snapshot, error in
            guard error == nil else { return }
            guard let snapshot = snapshot else { return }

            let dict = snapshot.data()
            let imageURL = dict?["imageURL"] as? String
            completion(imageURL ?? "")
        }
    }
    func uploadPicture(image: UIImage, completion: @escaping(() -> Void)) {

        ImageUploader.uploadImage(image: image, type: .chatRoomPicture) { imageURL in
            guard let chatRoomID = self.chatRoom?.id else { return }
            let room = COLLECTION_CHATROOMS.document(chatRoomID)

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
