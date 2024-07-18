//
//  SearchViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

final class SearchViewController: BaseViewController<SearchViewModel> {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LeftImageTitleButtonCell.self, forCellReuseIdentifier: LeftImageTitleButtonCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "search".localized()
        navigationController?.navigationBar.prefersLargeTitles = true
        setup()
    }
    
    private func setup() {
        view.addSubview(searchBar)
        view.addSubview(searchTableView)
        searchTableView.dataSource = vm
        searchTableView.delegate = vm
        searchBar.delegate = vm
        vm.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.searchTableView.reloadData()
            }
        }
        navigateUserProfile()
        setupConstraints()
    }
    
    private func setupConstraints(){
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchBar.snp.bottom).offset(16)
        }
    }
    
    private func navigateUserProfile() {
        vm.selectedUserID = { [weak self] userID in
            let vc = self?.router.guestUserProfileVC(with: userID) as! GuestUserProfileViewController
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
