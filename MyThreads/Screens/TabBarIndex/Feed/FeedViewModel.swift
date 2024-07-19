//
//  FeedViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit
import FirebaseAuth

class FeedViewModel: NSObject {
    var selectedUserID: ((String)->Void)?
    private var threads: [Thread] = []
    private var imagesLoading: Int = 0
    var allImagesLoaded: (() -> Void)?
    var commentButtonTapped: ((String) -> Void)?
    
    let currentUser = Auth.auth().currentUser
    
    func updateThreads(_ threads: [Thread]) {
        self.threads = threads
        self.imagesLoading = 1
        if threads.count == 0 {
            imageLoaded()
        }
    }
    
    private func imageLoaded() {
        imagesLoading -= 1
        if imagesLoading == 0 {
            allImagesLoaded?()
        }
    }
    
    func getThreads() async throws {
        let threads = try await ThreadsService.shared.getThreads()
        updateThreads(threads)
    }
    
    func getLikedThreads() async throws {
        guard let id = currentUser?.uid else {return}
        let threads = try await ThreadsService.shared.getLikedByCurrentUser(userID: id)
        updateThreads(threads)
    }
    
    func likeThread(threadId: String) async {
        guard let userID = currentUser?.uid else {return}
        do {
            try await ThreadsService.shared.likeThread(with: threadId, and: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func unLikeThread(threadId: String) async {
        guard let userID = currentUser?.uid else {return}
        do {
            try await ThreadsService.shared.unLikeThread(with: threadId, and: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
   
}

extension FeedViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
        DispatchQueue.main.async {
            cell.configure(with: self.threads[indexPath.row]) {
                self.imageLoaded()
            }
        }
    
        cell.commentButtonTapped = { [weak self] in
            self?.commentButtonTapped?(self?.threads[indexPath.row].id ?? "")
        }
        
        cell.likeButtonTapped = { [weak self] isLiked in
            guard let self else {return}
            if !isLiked {
                Task {
                    await self.unLikeThread(threadId: self.threads[indexPath.row].id)
                }
            } else {
                Task {
                    await self.likeThread(threadId: self.threads[indexPath.row].id)
                }
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUserID?(threads[indexPath.row].author)
    }
    
}
