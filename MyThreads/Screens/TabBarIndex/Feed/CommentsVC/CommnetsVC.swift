//
//  CommnetsVC.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 17.07.24.
//

import UIKit

final class CommentsVC: BaseViewController<CommentsVM> {
    
    private var mainStackView: VStack = {
        let stackView = VStack()
        return stackView
    }()
    
    private let repliesTV: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let bottomstackView: HStack = {
        let stackView = HStack()
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Replies"
        setup()
    }
    
    private func setup() {
        Task {
            do {
                try await vm.getComment()
            } catch {
                self.showAlert("error".localized(), error.localizedDescription)
            }
        }
        repliesTV.register(LeftImageTitleSubtitleCell.self, forCellReuseIdentifier: LeftImageTitleSubtitleCell.identifier)
        repliesTV.dataSource = vm
        view.addSubview(repliesTV)
        setupConstraints()
        
        vm.reloadTableView = {[weak self] in
            DispatchQueue.main.async {
                self?.repliesTV.reloadData()
            }
        }
    }
    
    private func setupConstraints() {
        repliesTV.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
