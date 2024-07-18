//
//  MoreViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 15.07.24.
//

import UIKit

final class MoreViewController: BaseViewController<MoreViewModel> {
    
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
        await MainActor.run  {
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
                print("about")
            case .help:
                print("help")
            case .language:
                self.changeLanguage()
            }
        }
    }
  
    private func changeLanguage() {
        let alert = UIAlertController(title: "doYouWantToChangeLanguage".localized(), message: "selectLanguage".localized(), preferredStyle: .actionSheet)
        let azButton = UIAlertAction(title: "az".localized(), style: .default) { [weak self] _ in
            self?.vm.changeLanguage(.az)
        }
        let enButton = UIAlertAction(title: "en".localized(), style: .default) { [weak self] _ in
            self?.vm.changeLanguage(.en)
        }
        alert.addAction(azButton)
        alert.addAction(enButton)
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))
        self.present(alert, animated: true)
    }
}
