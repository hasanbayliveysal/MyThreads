//
//  CommentsVM.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 17.07.24.
//

import UIKit

class CommentsVM: NSObject {
    var threadID: String
    
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
