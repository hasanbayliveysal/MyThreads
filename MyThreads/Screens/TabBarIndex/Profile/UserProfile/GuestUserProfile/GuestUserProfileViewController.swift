//
//  GuestUserProfileViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 11.07.24.
//

import UIKit
import FirebaseAuth

final class GuestUserProfileViewController: BaseViewController<UserProfileViewModel> {
    private var isFollowing: Bool? = nil
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let headerView: ProfileHeaderView = {
        let view = ProfileHeaderView()
        return view
    }()
    
    private var feedTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.6
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        vm.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.feedTableView.reloadData()
            }
        }
        headerView.selected = { [weak self] seleced in
            self?.vm.selectedFilter = seleced
            self?.fetchThreads()
        }
    }
    
    private func fetchThreads() {
        Task {
            do {
                try await vm.fetchThreads()
            } catch {
                showAlert("error".localized(), error.localizedDescription)
            }
        }
    }
    
    private func setupUI() {
        let rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        view.addSubview(headerView)
        view.addSubview(feedTableView)
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        feedTableView.dataSource = vm
        let currentUser = Auth.auth().currentUser
        guard let currentUserID = currentUser?.uid else {return}
        Task {
            showLoading(true)
            do {
                try await vm.fetchThreads()
                let user = try await vm.fetchUser()
                let isFollowing = user.followerIDs.contains(where: {$0 == currentUserID})
                headerView.configure(with: .init(name: user.fullname, username: user.username, image: user.profileImageUrl, bio: user.bio, followersCount: user.followerIDs.count), and: .GuestUser(isFollowing: isFollowing))
                self.isFollowing = isFollowing
            } catch {
                self.showAlert("error".localized(), "\(error.localizedDescription)")
            }
            showLoading(false)
        }
        setupConstraints()
        headerView.addTargetEditButton(target: self, action: #selector(didTapFollowButton), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        feedTableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            blurEffectView.isHidden = false
            activityIndicator.startAnimating()
        } else {
            blurEffectView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
}

extension GuestUserProfileViewController {
    @objc
    private func didTapMoreButton() {
        print("DEBUG More button clicked")
    }
    
    @objc
    private func didTapFollowButton() {
        isFollowing?.toggle()
        guard let isFollowing else {return}
        isFollowing ? isFollowingg() : isNotFollowing()
    }
    
    func isFollowingg() {
        Task {
            await vm.followUser()
        }
        headerView.editButton.setTitleColor(
            .black,
            for: .normal)
        headerView.editButton.backgroundColor = .white
        headerView.editButton.setTitle(
            "following".localized(),
            for: .normal)
    }
    
    func isNotFollowing() {
        Task {
            await vm.unfollowUser()
        }
        headerView.editButton.setTitleColor(
            .white,
            for: .normal)
        headerView.editButton.backgroundColor = .black
        headerView.editButton.setTitle(
            "follow".localized(),
            for: .normal)
    }
    
    
    
}
