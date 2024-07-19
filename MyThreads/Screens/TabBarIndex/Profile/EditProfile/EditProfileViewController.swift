//
//  EditProfileViewController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import UIKit

protocol SelectedImageDelegate: AnyObject {
    func setUserProfile(userData: UserData)
}

final class EditProfileViewController: UIViewController {
    weak var delegate: SelectedImageDelegate?
    private let vm = EditProfileViewModel()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let mainStackView: VStack = {
        let stackView = VStack()
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleSubtitleStackView: VStack = {
        let stackView = VStack()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let topStackView: HStack = {
        let stackView = HStack()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let rightImage: UserImageView = {
        let image = UserImageView(frame: .zero)
        return image
    }()
    
    private let bioStackView: VStack = VStack()
    
    private let bioInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "enteryourbio".localized()
        return textField
    }()
    
    private let linkStackView: VStack = VStack()
    
    private let linkInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "addlink".localized()
        return textField
    }()
    
    private let bottomStackView: HStack = {
        let stackView = HStack()
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let mySwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerForKeyboardNotifications()
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "edit".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done".localized(), style: .done, target: self, action: #selector(didTapDoneButton))
        
        [createTitleLabel(with: "name"), subtitleLabel].forEach(titleSubtitleStackView.addArrangedSubview)
        [titleSubtitleStackView, rightImage].forEach(topStackView.addArrangedSubview)
        [createTitleLabel(with: "bio"), bioInputField].forEach(bioStackView.addArrangedSubview)
        [createTitleLabel(with: "link"), linkInputField].forEach(linkStackView.addArrangedSubview)
        [createTitleLabel(with: "private"), mySwitch].forEach(bottomStackView.addArrangedSubview)
        
        [topStackView, Rectangle(), bioStackView, Rectangle(), linkStackView, Rectangle(), bottomStackView, Rectangle()]
            .forEach(mainStackView.addArrangedSubview)
        
        view.addSubview(containerView)
        containerView.addSubview(mainStackView)
        containerView.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        rightImage.clipsToBounds = true
        rightImage.layer.cornerRadius = 24
        containerView.layer.cornerRadius = 16
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
        containerView.layer.borderWidth = 1
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(containerView.snp.edges).inset(20)
        }
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        rightImage.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func createTitleLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.text = title.localized()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.bounds.height/4 + self.view.safeAreaInsets.bottom)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        rightImage.isUserInteractionEnabled = true
        let tapGestureRecognizerForImage = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        tapGestureRecognizerForImage.cancelsTouchesInView = false
        rightImage.addGestureRecognizer(tapGestureRecognizerForImage)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapDoneButton() {
        guard let image = rightImage.image else {
            showAlert("error".localized(), "Please select an image.")
            return
        }
        
        activityIndicator.startAnimating()
        
        Task {
            do {
                let userData = UserData(image: image, bio: bioInputField.text, link: linkInputField.text)
                try await vm.uploadUserData(userData: userData)
                await MainActor.run {
                    self.delegate?.setUserProfile(userData: userData)
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true)
                }
            } catch {
                print("Error uploading data: \(error.localizedDescription)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert("error".localized(), error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func didTapImageView() {
        createActionSheet { [weak self] sourceType in
            guard let self = self else { return }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
    }
    
    private func createActionSheet(completion: @escaping ((UIImagePickerController.SourceType) -> Void)) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "camera".localized(), style: .default) { _ in
            completion(.camera)
        })
        alert.addAction(UIAlertAction(title: "library".localized(), style: .default) { _ in
            completion(.photoLibrary)
        })
        alert.addAction(UIAlertAction(title: " cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }
    
    private func fetchCurrentUser() {
        Task {
            do {
                let user = try await vm.fetchCurrentUser()
                subtitleLabel.text = user.fullname
                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                    rightImage.kf.setImage(with: url)
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let pickedImage = info[.originalImage] as? UIImage {
                self.rightImage.image = pickedImage
                self.delegate?.setUserProfile(userData: UserData(image: pickedImage, bio: self.bioInputField.text, link: self.linkInputField.text))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
