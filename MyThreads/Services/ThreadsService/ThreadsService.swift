//
//  ThreadsService.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 13.07.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol ThreadsServiceProtocol {
    func addThreads(with thread: Thread) async throws
    func getThreads() async throws -> [Thread]
    func getOwnThreads(with id: String) async throws -> [Thread]
    func likeThread(with threadID: String, and userID: String) async throws
    func unLikeThread(with threadID: String, and userID: String) async throws
    func addComment(with comment: Thread.Comment, and threadID: String) async throws
    func getComment(with threadID: String) async throws -> [Thread.Comment]
    func getRepliedThread(with id: String) async throws -> [Thread]
    func getLikedByCurrentUser(userID: String) async throws -> [Thread]
}

class ThreadsService: ThreadsServiceProtocol {
    static let shared: ThreadsServiceProtocol = ThreadsService()
    let db = Firestore.firestore()
    
    func addThreads(with thread: Thread) async throws {
        do {
            let encodedThread = try Firestore.Encoder().encode(thread)
            _ = try await db.collection("threads").document(thread.id).setData(encodedThread)
        } catch {
            throw error
        }
    }
    
    func getThreads() async throws -> [Thread] {
        let snapshot = try await db.collection("threads")
            .order(by: "time", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
    }
    
    func getOwnThreads(with id: String) async throws -> [Thread] {
        let snapshot = try await db.collection("threads")
            .order(by: "time", descending: true)
            .getDocuments()
        let threads = try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
        return threads.filter({$0.author == id})
    }
    
    func getRepliedThread(with id: String) async throws -> [Thread] {
        let snapshot = try await db.collection("threads")
            .order(by: "time", descending: true)
            .getDocuments()
        let threads = try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
        return threads.filter(
            {$0.comments.contains(where: {$0.author == id})})
    }
    
    func likeThread(with threadID: String, and userID: String) async throws  {
        let threadRef = db.collection("threads").document(threadID)
        do {
            let threadSnapshot = try await threadRef.getDocument()
            if let threadData = threadSnapshot.data(), let likedBy = threadData["likedBy"] as? [String], likedBy.contains(userID) {
                return
            }
            
            try await threadRef.updateData([
                "likedBy": FieldValue.arrayUnion([userID])
            ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func unLikeThread(with threadID: String, and userID: String) async throws  {
        let threadRef = db.collection("threads").document(threadID)
        do {
            let threadSnapshot = try await threadRef.getDocument()
            if let threadData = threadSnapshot.data(), let likedBy = threadData["likedBy"] as? [String], !likedBy.contains(userID) {
                return
            }
            
            try await threadRef.updateData([
                "likedBy": FieldValue.arrayRemove([userID])
            ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addComment(with comment: Thread.Comment, and threadID: String) async throws {
        let threadRef = db.collection("threads").document(threadID)
        do {
            let document = try await threadRef.getDocument()
            var thread = try document.data(as: Thread.self)
            thread.comments.append(comment)
            try await threadRef.updateData([
                "comments": thread.comments.map { try? Firestore.Encoder().encode($0) }
            ])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getComment(with threadID: String) async throws -> [Thread.Comment] {
           let document = try await db.collection("threads").document(threadID).getDocument()
           let thread = try document.data(as: Thread.self)
           let comments = thread.comments.sorted(by: { $0.time > $1.time })
           return comments
    }
    
    func getLikedByCurrentUser(userID: String) async throws -> [Thread] {
        let snapshot = try await db.collection("threads")
            .order(by: "time", descending: true)
            .getDocuments()
        
        let threads =  try snapshot.documents.compactMap { document in
            try document.data(as: Thread.self)
        }
        return threads.filter({$0.likedBy.contains(where: {$0 == userID})})
    }
    
}
