//
//  FeedViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit
import FirebaseAuth

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    private let feedTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let reloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.circle"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
        navigationItem.title = "Threads"
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        setup()
        vm.allImagesLoaded = { [weak self] in
            self?.hideLoadingIndicator()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoadingIndicator()
        fetchThreads()
    }
    
    private func setup() {
        view.addSubview(feedTableView)
        feedTableView.dataSource = vm
        feedTableView.delegate = vm
        feedTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshThreads), for: .valueChanged)
        setupConstraints()
        pushCommentVC()
        pushUserVC()
    }
    
    private func setupConstraints() {
        feedTableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        setupActivityIndicatorAndBlur()
    }
    
    private func setupActivityIndicatorAndBlur() {
        blurView.isHidden = true
        view.addSubview(blurView)
        blurView.frame = view.bounds
        
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    @objc private func reloadButtonTapped() {
        showLoadingIndicator()
        fetchThreads()
    }
    
    @objc private func refreshThreads() {
        showRefreshIndicator()
        fetchThreads()
    }
    
    func fetchThreads() {
        Task {
            do {
                try await vm.getThreads()
                feedTableView.reloadData()
            } catch {
                showAlert("error".localized(), "\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                }
            }
        }
    }
    
    private func showLoadingIndicator() {
        blurView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        blurView.isHidden = true
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    private func showRefreshIndicator() {
        refreshControl.beginRefreshing()
        blurView.isHidden = false
    }
    
    private func pushCommentVC() {
        vm.commentButtonTapped = { [weak self] id in
            guard let self = self else { return }
            let vc = self.router.commentVC(threadID: id)
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true)
        }
    }
    
    private func pushUserVC() {
        let currentUser = Auth.auth().currentUser
        vm.selectedUserID = { [weak self] selectedUserID in
            if selectedUserID == currentUser?.uid {
                self?.tabBarController?.selectedIndex = 4
            } else {
                let vc = self?.router.guestUserProfileVC(with: selectedUserID)
                self?.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
            }
        }
    }
}


