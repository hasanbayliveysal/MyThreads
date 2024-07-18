//
//  CurrentUserProfileViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit
import FirebaseAuth

protocol SignOutDelegate {
    func didSignOut()
}

final class CurrentUserProfileViewController: BaseViewController<UserProfileViewModel> {
    var delegate: SignOutDelegate?
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
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0.8
        effectView.isHidden = true
        return effectView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchCurrentUser()
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
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        fetchThreads()
    }
    
    private func fetchThreads() {
        showLoading()
        Task {
            do {
                try await vm.fetchThreads()
                hideLoading()
            } catch {
                showAlert("error".localized(), error.localizedDescription)
                hideLoading()
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
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        headerView.addTargetEditButton(target: self, action: #selector(didTapEditButton), for: .touchUpInside)
        setupConstraints()
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
    
    private func fetchCurrentUser() {
        showLoading()
        Task {
            do {
                let user = try await vm.fetchUser()
                headerView.configure(with: .init(name: user.fullname, username: user.username, image: user.profileImageUrl, bio: user.bio, followersCount: user.followerIDs.count), and: .CurrentUser)
                hideLoading()
            } catch {
                print(error)
                hideLoading()
            }
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
    
    @objc
    private func didTapEditButton() {
        let vc = EditProfileViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.delegate = self
        present(navVC, animated: true)
    }
    
    @objc
    private func didTapMoreButton() {
        let vc = router.moreVC()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CurrentUserProfileViewController: SelectedImageDelegate {
    func setUserProfile(userData: UserData) {
        headerView.rightImage.image = userData.image
        headerView.bioLabel.text = userData.bio
    }
}
