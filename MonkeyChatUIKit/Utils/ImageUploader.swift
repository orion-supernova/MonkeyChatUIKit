//
//  ImagePicker.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 20.06.2022.
//

import UIKit
import Firebase

enum UploadType {

    case chatRoomPicture
    case profilePicture

    var filePath: StorageReference {

        let fileName = NSUUID().uuidString

        switch self {
            case .chatRoomPicture:
                return Storage.storage().reference(withPath: "/images/chatRoomPictures/\(fileName).jpg")
            case .profilePicture:
                return Storage.storage().reference(withPath: "/images/profilePictures/\(fileName).jpg")
        }
    }
}

struct ImageUploader {

    static func uploadImage(image: UIImage, type: UploadType, completion: @escaping(String) -> Void) {

        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        let ref = type.filePath

        ref.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                print("Failed to upload image. \(error!.localizedDescription)")
                return
            }

            print("Succesfully uploaded the image via ImageUploader!")

            ref.downloadURL { url, _ in
                guard let imageURL = url?.absoluteString else { return }
                completion(imageURL)
            }
        }

    }
}
