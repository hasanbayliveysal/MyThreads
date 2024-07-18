//
//  UploadViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit



final class UploadViewController: BaseViewController<UploadViewModel> {
  
    private let mainStackView: HStack = {
        let stackView = HStack()
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleSubtitleStackView: VStack = VStack()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "startathread".localized()
        return textField
    }()
    
    private let leftImage: UserImageView = {
        let image = UserImageView(frame: .zero)
        return image
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0
        return blurEffectView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        inputTextField.becomeFirstResponder()
        addTapGesture()
        inputTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .allEditingEvents)
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "newthreads".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "post".localized(), style: .done, target: self, action: #selector(didTapDoneButton))
        view.addSubview(mainStackView)
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        [titleLabel, inputTextField].forEach({titleSubtitleStackView.addArrangedSubview($0)})
        [leftImage, titleSubtitleStackView, clearButton].forEach({mainStackView.addArrangedSubview($0)})
        
        Task {
            do {
                let user = try await vm.fetchCurrentUser()
                titleLabel.text = user.username
                guard let urlString = user.profileImageUrl else {return}
                leftImage.kf.setImage(with: URL(string: urlString))
            } catch {
                self.showAlert("error".localized(), "\(error.localizedDescription)")
            }
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        leftImage.clipsToBounds = true
        leftImage.layer.cornerRadius = 32
        leftImage.snp.makeConstraints { make in
            make.size.equalTo(64)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        clearButton.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
    }
}

extension UploadViewController {
    
    @objc
    private func didTapDoneButton() {
        guard let thread = inputTextField.text,
              !thread.isEmpty else {
            self.showAlert("error".localized(), "cannotbeempty".localized())
            return
        }
        vm.postedThread = thread
        inputTextField.text = ""
        showActivityIndicator()
        Task {
            do {
                try await vm.addPost()
                hideActivityIndicator()
                tabBarController?.selectedIndex = 0
            } catch {
                hideActivityIndicator()
                showAlert("error".localized(), "\(error.localizedDescription)")
            }
        }
    }
    
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 1
        }
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 0
        }
    }
    
    @objc
    private func didTapView() {
        view.endEditing(true)
    }
    
    @objc
    private func textFieldDidBeginEditing() {
        guard let text = inputTextField.text else {
            return
        }
        clearButton.isHidden = text.isEmpty
    }
    
    @objc
    private func didTapClearButton() {
        inputTextField.text = ""
        clearButton.isHidden = true
    }
}

