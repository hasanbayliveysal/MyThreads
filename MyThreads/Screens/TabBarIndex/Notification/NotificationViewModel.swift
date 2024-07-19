//
//  NotificationViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class NotificationViewModel: NSObject {
    var selectedUser: ((String) ->())?
    private var selectedActivity: Activities = .Follow {
        didSet {
            Task {
                await getUsers()
            }
            reloadTableView?()
        }
    }
    var loadingStateChanged: ((Bool) -> Void)?
    var reloadTableView: (() -> Void)?
    private var activities: [Activities] = [
        .Follow, .Replies, .Mentions
    ]
    private var users: [User] = [] {
        didSet {
            reloadTableView?()
        }
    }
    
    func getUsers() async  {
        loadingStateChanged?(true)
        users.removeAll()
        do {
            switch selectedActivity {
            case .Follow:
                self.users = try await ActivityService.shared.getFollowers()
            case .Replies:
                self.users = try await ActivityService.shared.getRepliedUsers()
            case .Mentions:
                self.users = try await ActivityService.shared.getLikedUsers()
            }
            loadingStateChanged?(false)
        } catch {
            print(error.localizedDescription)
            loadingStateChanged?(false)
        }
    }
    private func fetchFollowedUserIDs() async throws -> [String] {
        return try await UserService.shared.fetchFollowedUsersID()
    }
}


extension NotificationViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeftImageTitleButtonCell.identifier, for: indexPath) as! LeftImageTitleButtonCell
        cell.configure(with: self.users[indexPath.row], activity: selectedActivity)
        let user = self.users[indexPath.row]
        Task {
            do {
                let followedUserIDs = try await fetchFollowedUserIDs()
                let isFollowing = followedUserIDs.contains { $0 == user.id }
                DispatchQueue.main.async {
                    isFollowing ? cell.isFollowingg() : cell.isNotFollowing()
                    cell.isFollowing = isFollowing
                }
            } catch {
                print("Error fetching followed users: \(error)")
            }
        }

        cell.isFollowingClousure = { isFollowing in
            Task {
                do {
                    if isFollowing {
                        try await UserService.shared.addFollower(with: user.id)
                    } else {
                        try await UserService.shared.removeFollower(with: user.id)
                    }
                } catch {
                    print("Error updating follow status: \(error)")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser?(users[indexPath.row].id)
    }
}

extension NotificationViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CenterTitleCVCell.identifier, for: indexPath) as! CenterTitleCVCell
        cell.configure(with: activities[indexPath.row].rawValue)
        if indexPath.row == 0 {
            cell.setSelected(true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CenterTitleCVCell {
            cell.setSelected(true)
        }
        selectedActivity = (activities[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CenterTitleCVCell {
            cell.setSelected(false)
        }
    }
}
