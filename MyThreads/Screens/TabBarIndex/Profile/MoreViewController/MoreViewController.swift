//
//  MoreViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 15.07.24.
//


import UIKit
import MessageUI

final class MoreViewController: BaseViewController<MoreViewModel>, MFMailComposeViewControllerDelegate {
    
    private var moreTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MoreTVCell.self, forCellReuseIdentifier: MoreTVCell.identifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("logout".localized(), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(didTapLogOut), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "more".localized()
        moreTableView.dataSource = vm
        moreTableView.delegate = vm
        performSelectedOperation()
        setupConstraints()
    }
    
    private func setupConstraints() {
        let rightBarButtonItem = UIBarButtonItem(customView: logOutButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        view.addSubview(moreTableView)
        moreTableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func didTapLogOut() {
        let alert = UIAlertController(title: nil, message: "doYouWantToTogout".localized(), preferredStyle: .alert)
        let okButton = UIAlertAction(title: "ok".localized(), style: .default) {[weak self] _ in
            self?.logOut()
        }
        let cancelButton = UIAlertAction(title: "cancel".localized(), style: .destructive)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    private func logOut() {
        Task {
            do {
                try await vm.signOut()
                await performPostLoginOperations()
            }
        }
    }
    
    private func performPostLoginOperations() async {
        vm.setUserSignedOut()
        await MainActor.run {
            let vc = router.loginVC()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
    
    private func performSelectedOperation() {
        vm.selectedRow = { [weak self] selectedRow in
            guard let self else {return}
            switch selectedRow {
            case .liked:
                self.navigationController?.pushViewController(self.router.likedVC(), animated: true)
            case .about:
                self.openInstagramProfile()
            case .help:
                self.presentMailCompose()
            case .language:
                self.changeLanguage()
            }
        }
    }
    
    private func presentMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert("Mail services are not available", "Please configure your email in the Mail app.")
            return
        }
        
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["hasanbayliveysaldev@gmail.com"])
        mailComposeViewController.setSubject("Help Request")
        
        self.present(mailComposeViewController, animated: true)
    }
    
    private func openInstagramProfile() {
        let username = "hasanbayli_veysal"
        let appURL = URL(string: "instagram://user?username=\(username)")!
        let webURL = URL(string: "https://instagram.com/\(username)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:])
        } else {
            UIApplication.shared.open(webURL, options: [:])
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func changeLanguage() {
        let alert = UIAlertController(title: "doYouWantToChangeLanguage".localized(), message: "selectLanguage".localized(), preferredStyle: .actionSheet)
        let azButton = UIAlertAction(title: "az".localized(), style: .default) { [weak self] _ in
            self?.vm.changeLanguage(.az)
            self?.resetAppState()
        }
        let enButton = UIAlertAction(title: "en".localized(), style: .default) { [weak self] _ in
            self?.vm.changeLanguage(.en)
            self?.resetAppState()
        }
        alert.addAction(azButton)
        alert.addAction(enButton)
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func resetAppState() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let window = scene.windows.first else { return }
        window.rootViewController = TabBarController()
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
