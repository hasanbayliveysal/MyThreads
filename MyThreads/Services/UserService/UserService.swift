//
//  UserService.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 05.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User?
    func fetchUsers() async throws -> [User]
    func uploadUserData(userData: UserData, imageUrl: String?) async throws
    func addFollower(with id: String) async throws
    func fetchUserByID(with id: String) async throws -> User
    func fetchFollowedUsersID() async throws -> [String] 
}

class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    func fetchCurrentUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else { return nil }
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        return user
    }
    
    func fetchUsers() async throws -> [User] {
        guard let uid = auth.currentUser?.uid else { return [] }
        let snapshot = try await db.collection("users").getDocuments()
        let users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
        return users.filter { $0.id != uid }
    }
    
    func fetchSearchedUsers() async throws -> [User] {
        guard let uid = auth.currentUser?.uid else { return [] }
        let snapshot = try await db.collection("users").getDocuments()
        let users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
        print(users)
        return users.filter { $0.id != uid }
    }
    
    func uploadUserData(userData: UserData, imageUrl: String?) async throws {
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        do {
            try await userRef.updateData([
                "bio": userData.bio as Any,
                "link": userData.link as Any,
                "isAccountPrivate": userData.privateAccount,
                "profileImageUrl": imageUrl as Any
            ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addFollower(with id: String) async throws {
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        let followingUser = db.collection("users").document(id)
        
        do {
            // Check if the user is already following the other user
            let userSnapshot = try await userRef.getDocument()
            if let userData = userSnapshot.data(), let followingIDs = userData["followingIDs"] as? [String], followingIDs.contains(id) {
                // User is already following, no need to add again
                return
            }

            try await userRef.updateData([
                "followingIDs": FieldValue.arrayUnion([id])
            ])
            try await followingUser.updateData([
                "followerIDs": FieldValue.arrayUnion([user.uid])
            ])
        } catch {
            print(error.localizedDescription)
        }
    }

    func removeFollower(with id: String) async throws {
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        let followingUser = db.collection("users").document(id)
        
        do {
            // Check if the user is actually following the other user
            let userSnapshot = try await userRef.getDocument()
            if let userData = userSnapshot.data(), let followingIDs = userData["followingIDs"] as? [String], !followingIDs.contains(id) {
                // User is not following, no need to remove
                return
            }

            try await userRef.updateData([
                "followingIDs": FieldValue.arrayRemove([id])
            ])
            try await followingUser.updateData([
                "followerIDs": FieldValue.arrayRemove([user.uid])
            ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUserByID(with id: String) async throws -> User {
        let snapshot = try await db.collection("users").document(id).getDocument()
        let user = try snapshot.data(as: User.self)
        return user
    }
    
    func fetchFollowedUsersID() async throws -> [String] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let userData = snapshot.data(), let followingIDs = userData["followingIDs"] as? [String] else { return [] }
        
        return followingIDs
    }

    
}
