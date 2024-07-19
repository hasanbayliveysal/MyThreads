//
//  InitialViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 20.07.24.
//

import UIKit

final class InitialViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pattern")
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private let mainStackView: HStack = {
        let mainStackView = HStack()
        mainStackView.distribution = .equalSpacing
        return mainStackView
    }()
    
    private let verticalStackView: VStack = {
        let stackView = VStack()
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
      
        let loginLabel = UILabel()
        loginLabel.text = "Log in or"
        loginLabel.font = UIFont.systemFont(ofSize: 16)
        loginLabel.textColor = .gray
        verticalStackView.addArrangedSubview(loginLabel)
        
     
        let appLogo = UIImageView()
        appLogo.image = UIImage(named: "appIcon")
        appLogo.contentMode = .scaleAspectFit
        
        appLogo.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
       
        
        let userNameLabel = UILabel()
        userNameLabel.text = "Sign up"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        userNameLabel.textColor = .black
        verticalStackView.addArrangedSubview(userNameLabel)
        [verticalStackView, appLogo].forEach({mainStackView.addArrangedSubview($0)})
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        containerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top).inset(16)
        }
        addGesture()
    }
    
    private func addGesture() {
        containerView.isUserInteractionEnabled =  true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func didTapView() {
        let router = Router()
        let navVc = UINavigationController(rootViewController: router.loginVC())
        navVc.modalPresentationStyle = .fullScreen
        self.present(navVc, animated: true)
    }
}
