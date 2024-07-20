//
//  FeedViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit
import FirebaseAuth
import MessageUI

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    private let feedTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
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
        handleThreeDotButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        fetchThreads()
    }
    
    @objc private func refreshThreads() {
        showRefreshIndicator()
        fetchThreads()
    }
    
    func fetchThreads() {
        showLoadingIndicator()
        Task {
            do {
                try await vm.getThreads()
                feedTableView.reloadData()
            } catch {
                showAlert("error".localized(), "\(error.localizedDescription)")
                self.hideLoadingIndicator()
            }
        }
    }
    
    private func showLoadingIndicator() {
        blurView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.blurView.isHidden = true
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showRefreshIndicator() {
        refreshControl.beginRefreshing()
        blurView.isHidden = false
    }
    
    private func pushCommentVC() {
        vm.commentButtonTapped = { [weak self] id in
            guard let self = self else { return }
            let vc = self.router.commentVC(threadID: id) as! CommentsVC
            vc.delegate = self
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
    
    private func handleThreeDotButton() {
        vm.threeDotButtonTapped = { [weak self] (threadID, threadAuthorID) in
            guard let self = self else { return }
            let currentUserID = Auth.auth().currentUser?.uid
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if threadAuthorID == currentUserID {
                // Option to delete the thread
                let deleteAction = UIAlertAction(title: "Delete Thread", style: .destructive) { _ in
                    self.showDeleteConfirmationAlert(threadID: threadID)
                }
                actionSheet.addAction(deleteAction)
            } else {
                // Option to report the thread
                let reportAction = UIAlertAction(title: "Report Thread", style: .default) { _ in
                    self.reportThread(threadID: threadID)
                }
                actionSheet.addAction(reportAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true)
        }
    }
    
    private func showDeleteConfirmationAlert(threadID: String) {
        let alert = UIAlertController(title: "Delete Thread".localized(), message: "Are you sure you want to delete this thread?".localized(), preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "delete".localized(), style: .destructive) { _ in
            Task {
                do {
                    try await self.vm.deleteThread(with: threadID)
                    self.fetchThreads()
                } catch {
                    self.showAlert("error".localized(), error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func reportThread(threadID: String) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert("Mail Services are not available", "Please configure your mail account in order to send emails.")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["hasanbayliveysalev@gmail.com"])
        composeVC.setSubject("Report User Thread")
        composeVC.setMessageBody("https://mythreads.com/\(threadID)", isHTML: false)
        
        present(composeVC, animated: true)
    }
}

extension FeedViewController: RepliesDelegate {
    func repliesDidChange() {
        self.fetchThreads()
    }
}

extension FeedViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
