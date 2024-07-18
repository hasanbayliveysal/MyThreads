//
//  RegisterViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

final class RegisterViewController: BaseViewController<RegisterViewModel> {
    
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
    
    private let fullNameTextField: InputTextField = {
        let tf = InputTextField()
        tf.placeholder = "enterFullname".localized()
        return tf
    }()
    
    private let usernameTextField: InputTextField = {
        let tf = InputTextField()
        tf.placeholder = "enterUsername".localized()
        return tf
    }()
    
    private lazy var registerButton: BaseButton = {
        let button = BaseButton()
        button.setTitle("register".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
    }
    
    private func setup() {
        [appIcon, mainStackView].forEach({view.addSubview($0)})
        [emailTextField, passwordTextField, fullNameTextField,usernameTextField,registerButton
        ].forEach({mainStackView.addArrangedSubview($0)})
        mainStackView.setCustomSpacing(24, after: usernameTextField)
        setupConstraints()
    }
    
    private func setupConstraints() {
        appIcon.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(mainStackView.snp.top).offset(-40)
            make.size.equalTo(100)
        }
        mainStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.trailing.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc func didTapRegister() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let fullname = fullNameTextField.text, !fullname.isEmpty,
              let username = usernameTextField.text, !username.isEmpty
        else {
            self.showAlert("error", "fillAll")
            return
        }
        vm.newUser = .init(email: email, password: password, fullname: fullname, username: username)
        Task {
            do {
                try await vm.register()
                self.showAlert("success", "gotoLogin")
            } catch {
                self.showAlert("error", error.localizedDescription)
            }
        }
    }
}
