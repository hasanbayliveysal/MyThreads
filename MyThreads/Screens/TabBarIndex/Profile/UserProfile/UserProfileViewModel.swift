//
//  UserProfileViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 11.07.24.
//

import UIKit
import FirebaseAuth

class UserProfileViewModel: NSObject {
    let currentUser = Auth.auth().currentUser
    var userID: String? = nil
    var reloadTableView: (()->Void)?
    var selectedFilter: ProfileThreadsFilter = .threads
    private var threads: [Thread] = [] {
        didSet {
            reloadTableView?()
        }
    }
    
    init(userID: String? = nil) {
        guard let userID  else {
            self.userID = currentUser?.uid
            return
        }
        self.userID = userID
    }
    
    func likeThread(threadId: String) async {
        guard let currentUserID = currentUser?.uid else {return}
        do {
            try await ThreadsService.shared.likeThread(with: threadId, and: currentUserID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func unLikeThread(threadId: String) async {
        guard let currentUserID = currentUser?.uid else {return}
        do {
            try await ThreadsService.shared.unLikeThread(with: threadId, and: currentUserID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchThreads() async throws {
        guard let userID else {return}
        switch selectedFilter {
        case .threads:
            print("threads")
            threads = try await ThreadsService.shared.getOwnThreads(with: userID)
        case .replies:
            print("replies")
            threads = try await ThreadsService.shared.getRepliedThread(with: userID)
        }
    }
    
    func fetchUser() async throws -> User {
        return try await UserService.shared.fetchUserByID(with: userID ?? "")
    }
}

extension UserProfileViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
        cell.configure(with: threads[indexPath.row]) {
            //
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
}
