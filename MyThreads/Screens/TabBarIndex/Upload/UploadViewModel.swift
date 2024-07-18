//
//  UploadViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit
import FirebaseAuth

class UploadViewModel: NSObject {
    var textFieldDidBeginEditing: ((Bool)->())? = nil
    private var auth = Auth.auth()
    var postedThread: String? = nil
    
    func fetchCurrentUser() async throws -> User {
        guard let user = try await UserService.shared.fetchCurrentUser() else {
            return .init(id: "", fullname: "Test", email: "test@gmail.com", username: "testtest", isAccountPrivate: false)
        }
        return user
    }
    
    func fetchCurrentUserID() -> String {
        guard let currentUser = auth.currentUser else {
            return ""
        }
        return currentUser.uid
    }
    
    
    
    func addPost() async throws {
        let userID = fetchCurrentUserID()
        guard let postedThread else {
            return
        }
        let thread: Thread = Thread(id: UUID().uuidString,
                                    author: userID,
                                    thread: postedThread,
                                    time: Date())
       
        do {
            try await ThreadsService.shared.addThreads(with: thread)
        } catch {
            throw error
        }
    }
}

