//
//  ProfileViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 13.05.2023.
//

import UIKit

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
}
