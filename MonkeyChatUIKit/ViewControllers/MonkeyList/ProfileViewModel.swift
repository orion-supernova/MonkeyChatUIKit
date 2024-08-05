//
//  ProfileViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 13.05.2023.
//

import UIKit
import FirebaseStorage

final class ProfileViewModel {

    func saveProfilePictureToDisk(image: UIImage, completion: (Bool) -> Void) {

        // Convert to Data
        guard let data = image.pngData() else { return }
        let fileName = "MonkeyChatProfilePicture"

        // Create URL
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("\(fileName).png")

        do {
            // Write to Disk
            try data.write(to: url)
            completion(true)

        } catch {
            print("Unable to Write Data to Disk (\(error))")
            completion(false)
        }
    }

    func getProfilePictureFromDisk(completion: @escaping ((success: Bool, image: UIImage?)) -> Void ) {
        let fileName = "MonkeyChatProfilePicture"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("\(fileName).png")
        var urlString = url.absoluteString
        let prefix = "file://"
        if urlString.localizedStandardContains(prefix) {
            for _ in 1..<8 {
                let hm = urlString.dropFirst()
                urlString = String(hm)
            }
        }
        let image = UIImage(contentsOfFile: urlString)
        if let image {
            completion((true, image))
        } else {
            completion((false, nil))
        }
    }

    func getProfilePictureFromServer(completion: @escaping (String) -> Void) {
        guard let userID = AppGlobal.shared.userID else { return }

        COLLECTION_USERS.document(userID).getDocument { snapshot, error in
            guard error == nil else { return }
            guard let snapshot = snapshot else { return }

            let dict = snapshot.data()
            let imageURL = dict?["imageURL"] as? String
            completion(imageURL ?? "")
        }
    }

    func uploadProfilePictureToServer(image: UIImage, completion: @escaping((Bool) -> Void))  {
        guard let userID = AppGlobal.shared.userID else { return }
        let user = COLLECTION_USERS.document(userID)
        user.getDocument { snapshot, error in
            guard error == nil, snapshot != nil else {
                completion(false)
                return
            }
            guard let dict = snapshot?.data() else { return completion(false) }
            let imageURL = dict["imageURL"] as? String ?? ""
            if imageURL.isEmpty == false {
                self.deletePreviousImageFromStorage(url: imageURL)
            }

            ImageUploader.uploadImage(image: image, type: .profilePicture) { imageURL in
                let imageURLData = ["imageURL": imageURL] as [String: Any]
                user.updateData(imageURLData) { error in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }

    func deletePreviousImageFromStorage(url: String) {
        let storage = Storage.storage()
        storage.reference(forURL: url).delete { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }
}
