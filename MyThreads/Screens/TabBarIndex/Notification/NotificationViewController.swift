//
//  NotificationViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//
//
//  NotificationViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

final class NotificationViewController: BaseViewController<NotificationViewModel> {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: (view.bounds.width)/3, height: 38)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 2, left: 16, bottom: 2, right: 16)
        return collectionView
    }()
    
    private let activityTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        Task {
            await vm.getUsers()
        }
        view.backgroundColor = .white
        navigationItem.title = "Activity"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(collectionView)
        view.addSubview(activityTableView)
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        
        activityTableView.delegate = vm
        activityTableView.dataSource = vm
        activityTableView.register(LeftImageTitleButtonCell.self, forCellReuseIdentifier: LeftImageTitleButtonCell.identifier)
        activityTableView.refreshControl = refreshControl
        
        collectionView.delegate = vm
        collectionView.dataSource = vm
        collectionView.register(CenterTitleCVCell.self, forCellWithReuseIdentifier: CenterTitleCVCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        setupConstraints()
        
        vm.reloadTableView = { [weak self] in
            print("reloading")
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.activityTableView.reloadData()
            }
        }
        
        vm.loadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
        }
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(38)
        }
        
        activityTableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func refreshData() {
        Task {
            await vm.getUsers()
        }
    }
    
    private func showLoading() {
        blurEffectView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        blurEffectView.isHidden = true
        activityIndicator.stopAnimating()
    }
}
