//
//  EditProfileViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 07.07.24.
//

import UIKit

class EditProfileViewModel {
    
    func uploadUserData(userData: UserData)  async throws {
        Task {
            let imageUrl = try await uploadImage(image: userData.image)
            do {
                try await UserService.shared.uploadUserData(userData: userData, imageUrl: imageUrl)
            }
        }
      
    }
    
    private func uploadImage(image: UIImage) async throws -> String? {
        do{
          return try await StorageService.shared.uploadImage(image: image)
        } catch {
            return nil
        }
    }
    
    func fetchCurrentUser() async throws -> User {
        guard let user = try await UserService.shared.fetchCurrentUser() else {
            return .init(id: "", fullname: "Test", email: "test@gmail.com", username: "testtest", isAccountPrivate: false)
        }
        return user
    }
  
}

struct UserData {
    let image: UIImage
    let bio: String?
    let link: String?
    let privateAccount: Bool = false
}
