//
//  NotificationViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class NotificationViewModel: NSObject {
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
}


extension NotificationViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeftImageTitleButtonCell.identifier, for: indexPath) as! LeftImageTitleButtonCell
        cell.configure(with: self.users[indexPath.row], activity: selectedActivity)
        return cell
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
