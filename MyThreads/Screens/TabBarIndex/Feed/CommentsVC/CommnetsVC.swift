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
    
    private let bottomView: CenterInputButtonView = {
        let view = CenterInputButtonView()
        view.backgroundColor = .white
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "replies".localized()
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
        view.addSubview(bottomView)
        setupConstraints()
        
        vm.reloadTableView = {[weak self] in
            DispatchQueue.main.async {
                self?.repliesTV.reloadData()
            }
        }
        bottomView.postButtunTapped = { [weak self] postedText in
            guard let postedText else {
                self?.showAlert("error".localized(), "cannotbeempty".localized())
                return
            }
            Task {
                await self?.vm.addComment(postedText: postedText)
            }
            
        }
    }
    
    private func setupConstraints() {
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        repliesTV.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top).offset(-16)
        }
    }
}
