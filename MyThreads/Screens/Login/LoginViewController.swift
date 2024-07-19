//
//  LoginViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 01.07.24.
//

import UIKit
import SnapKit

final class LoginViewController: BaseViewController<LoginViewModel> {
    
    private let appIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "appIcon")
        return image
    }()
    
    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    private let emailTextField: InputTextField = {
        let tf = InputTextField()
        tf.placeholder = "enterEmail".localized()
        return tf
    }()
    
    private let passwordTextField: SecureTextField = {
        let tf = SecureTextField()
        tf.placeholder = "enterPassword".localized()
        return tf
    }()
    
    private lazy var loginButton: BaseButton = {
        let button = BaseButton()
        button.setTitle("login".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    private let passwordStackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.axis = .horizontal
        return sv
    }()
    
    private let forgotPassword: UIButton = {
        let button = UIButton()
        button.setTitle("forgotPassword".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let bottomStackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .center
        sv.axis = .horizontal
        return sv
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "donthaveacc".localized()
        label.textColor = .black
        return label
    }()
    
    private lazy var signUp: UIButton = {
        let button = UIButton()
        button.setTitle("signup".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
    }
    
    private func setup() {
        [appIcon, mainStackView, bottomStackView, activityIndicator].forEach({view.addSubview($0)})
        [UIView(), forgotPassword].forEach({passwordStackView.addArrangedSubview($0)})
        [bottomLabel, signUp].forEach({bottomStackView.addArrangedSubview($0)})
        [emailTextField, passwordTextField,passwordStackView,loginButton
        ].forEach({mainStackView.addArrangedSubview($0)})
        mainStackView.setCustomSpacing(24, after: passwordTextField)
        setupConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        appIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mainStackView.snp.top).offset(-40)
            make.size.equalTo(100)
        }
        mainStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.trailing.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension LoginViewController {
    @objc func didTapRegisterButton() {
        navigationController?.pushViewController(router.registerVC(), animated: true)
    }
    
    @objc func didTapLoginButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.showAlert("error", "fillAll")
            return
        }
        
        activityIndicator.startAnimating()
        
        vm.email = email
        vm.password = password
        Task {
            do {
                try await vm.login()
                await performPostLoginOperations()
            } catch {
                self.activityIndicator.stopAnimating()
                self.showAlert("error", error.localizedDescription)
            }
        }
    }

    func performPostLoginOperations() async {
        vm.setUserLoggedIn()
        await MainActor.run {
            let vc = TabBarController()
            vc.modalPresentationStyle = .fullScreen
            self.activityIndicator.stopAnimating()
            self.present(vc, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

