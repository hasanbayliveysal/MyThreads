//
//  ImageUploader.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 09.07.24.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

protocol StorageServiceProtocol {
    func uploadImage(image: UIImage) async throws -> String?
    func getUserImage() async throws -> String
}

class StorageService: StorageServiceProtocol {
    static let shared: StorageServiceProtocol = StorageService()
    
    let storageRef = Storage.storage().reference()
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    func uploadImage(image: UIImage) async throws -> String? {
        guard let currentUser else {
            return nil
        }
        let imageRef = storageRef.child("\(currentUser.uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            return nil
        }
        do {
            let _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image ", error.localizedDescription)
            return nil
        }
    }
    
//    func uploadUserImage(with imageUrl: String) async throws {
//        guard let currentUser else {
//            return
//        }
//        let userRef = db.collection("users").document(currentUser.uid)
//        do {
//            try await userRef.updateData(["profileImageUrl": imageUrl])
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    func getUserImage() async throws -> String {
        //        guard let currentUser else {
        //            return
        //        }
        return ""
    }
}
