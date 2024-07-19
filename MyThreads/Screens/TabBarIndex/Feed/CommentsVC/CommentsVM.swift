//
//  CommentsVM.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 17.07.24.
//

import UIKit
import FirebaseAuth

class CommentsVM: NSObject {
    var threadID: String
    var currentUser = Auth.auth().currentUser
    
    init(threadID: String) {
        self.threadID = threadID
    }
    
    var reloadTableView: (()->Void)?
    private var comments: [Thread.Comment] = [] {
        didSet {
            reloadTableView?()
        }
    }
    
    func getComment() async throws {
        self.comments = try await ThreadsService.shared.getComment(with: threadID)
    }
    
    func addComment(postedText: String) async {
        guard let userID = currentUser?.uid else {return}
        do {
            try await ThreadsService.shared.addComment(with: .init(author: userID, title: postedText, time: Date()), and: threadID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}

extension CommentsVM: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeftImageTitleSubtitleCell.identifier, for: indexPath) as! LeftImageTitleSubtitleCell
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}
