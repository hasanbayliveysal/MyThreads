//
//  SearchViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

//
//  SearchViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//
import UIKit
import FirebaseAuth

class SearchViewModel: NSObject {
    let auth = Auth.auth()
    private var searchedUsers: [User] = [] {
        didSet {
            DispatchQueue.main.async {
                self.reloadTableView?()
            }
        }
    }
    var reloadTableView: (() -> Void)?
    var selectedUserID: ((String) -> Void)?
    private var users: [User] = []

    override init() {
        super.init()
        Task {
            do {
                try await fetchUsers()
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }

    private func fetchUsers() async throws {
        print("DEBUG: Fetching users...")
        self.users = try await UserService.shared.fetchSearchedUsers()
        self.searchedUsers = users
    }

    private func fetchFollowedUserIDs() async throws -> [String] {
        return try await UserService.shared.fetchFollowedUsersID()
    }
}

extension SearchViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeftImageTitleButtonCell.identifier, for: indexPath) as! LeftImageTitleButtonCell

        guard indexPath.row < searchedUsers.count else { return cell }
        
        let user = searchedUsers[indexPath.row]
        cell.configure(with: user)
        
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
}

extension SearchViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < searchedUsers.count else { return }
        selectedUserID?(searchedUsers[indexPath.row].id)
    }
}

extension SearchViewModel: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchedUsers = []
            return
        }
        
        searchedUsers = users.filter { $0.username.lowercased().contains(searchText.lowercased()) }
    }
}
