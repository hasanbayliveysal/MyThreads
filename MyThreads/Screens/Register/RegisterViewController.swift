//
//  RegisterViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//
import UIKit
import SnapKit

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
        sv.spacing = 6
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.isHidden = true
        return blurEffectView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
    }
    
    private func setup() {
        [appIcon, mainStackView, blurEffectView, activityIndicator].forEach({view.addSubview($0)})
        [emailTextField, passwordTextField, fullNameTextField, usernameTextField, registerButton].forEach({mainStackView.addArrangedSubview($0)})
        mainStackView.setCustomSpacing(8, after: usernameTextField)
        setupConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(registerButton)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(registerButton)
        }
    }
    
    @objc func didTapRegister() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let fullname = fullNameTextField.text, !fullname.isEmpty,
              let username = usernameTextField.text, !username.isEmpty else {
            self.showAlert("error", "fillAll")
            return
        }
        
        vm.newUser = .init(email: email, password: password, fullname: fullname, username: username)
        
        showLoading(true)
        
        Task {
            do {
                try await vm.register()
                showLoading(false)
                self.showAlert("success", "gotoLogin")
            } catch {
                showLoading(false)
                self.showAlert("error", error.localizedDescription)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showLoading(_ show: Bool) {
        blurEffectView.isHidden = !show
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        registerButton.isEnabled = !show
    }
}
