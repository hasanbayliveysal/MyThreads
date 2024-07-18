//
//  ActivityService.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 18.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ActivityServiceProtocol {
    func getFollowers() async throws -> [User]
    func getLikedUsers() async throws -> [User]
    func getRepliedUsers() async throws -> [User]
}

class ActivityService: ActivityServiceProtocol {
    static let shared: ActivityServiceProtocol = ActivityService()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    private init() {}
    
    func getFollowers() async throws -> [User] {
        var user: [User] = []
        guard let currentUser = auth.currentUser else {
            return []
        }
        
        let snapshot = try await db.collection("users").document(currentUser.uid).getDocument()
        let data = try snapshot.data(as: User.self)
        let followerIDs = data.followerIDs
        for id in followerIDs {
            user.append(try await UserService.shared.fetchUserByID(with: id))
        }
        return user
    }
    
    func getLikedUsers() async throws -> [User] {
        var user: [User] = []
        guard let currentUser = auth.currentUser else {
            return []
        }
        
        let snapshot = try await db.collection("threads")
            .getDocuments()
        
        var threads = try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
        threads = threads.filter({$0.author == currentUser.uid})
        
        for thread in threads {
            for id in thread.likedBy {
                if id != currentUser.uid {
                    user.append(try await UserService.shared.fetchUserByID(with: id))
                }
            }
        }
        return user
    }
    
    func getRepliedUsers() async throws -> [User] {
        var user: [User] = []
        guard let currentUser = auth.currentUser else {
            return []
        }
        
        let snapshot = try await db.collection("threads")
            .getDocuments()
        
        var threads = try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
        threads = threads.filter({$0.author == currentUser.uid})
        
        for thread in threads {
            for reply in thread.comments {
                if reply.author != currentUser.uid {
                    user.append(try await UserService.shared.fetchUserByID(with: reply.author))
                }
            }
        }
        return user
    }
    

}
