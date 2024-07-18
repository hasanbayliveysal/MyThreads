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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCurrentUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "edit".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done".localized(), style: .done, target: self, action: #selector(didTapDoneButton))
        
        [createTitleLabel(with: "name"), subtitleLabel].forEach({ titleSubtitleStackView.addArrangedSubview($0) })
        [titleSubtitleStackView, rightImage].forEach({ topStackView.addArrangedSubview($0) })
        [createTitleLabel(with: "bio"), bioInputField].forEach({ bioStackView.addArrangedSubview($0) })
        [createTitleLabel(with: "link"), linkInputField].forEach({ linkStackView.addArrangedSubview($0) })
        [createTitleLabel(with: "private"), mySwitch].forEach({ bottomStackView.addArrangedSubview($0) })
        
        [topStackView, Rectangle(),
         bioStackView, Rectangle(),
         linkStackView, Rectangle(),
         bottomStackView, Rectangle()]
            .forEach({ mainStackView.addArrangedSubview($0) })
        
        view.addSubview(containerView)
        containerView.addSubview(mainStackView)
        containerView.addSubview(activityIndicator)
        
        setupConstraints()
        addTapGestureRecognizer()
        
        
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
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        rightImage.isUserInteractionEnabled = true
        rightImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapDoneButton() {
        guard let image = rightImage.image else {
            return
        }
        
        activityIndicator.startAnimating()
        
        Task {
            do {
                try await vm.uploadUserData(userData: .init(image: image, bio: bioInputField.text, link: linkInputField.text))
                
                // Update CurrentUserVC with new data
                delegate?.setUserProfile(userData: .init(image: image, bio: bioInputField.text, link: linkInputField.text))
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true)
                }
            } catch {
                // Handle error
                print("Error uploading data: \(error.localizedDescription)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    // Show alert or handle error
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
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func createActionSheet(completion: @escaping ((UIImagePickerController.SourceType) -> Void)) {
        let alert = UIAlertController(title: "selecttype".localized(), message: "", preferredStyle: .actionSheet)
        let cameraButton = UIAlertAction(title: "camera".localized(), style: .default) { _ in
            completion(.camera)
        }
        let libraryButton = UIAlertAction(title: "library".localized(), style: .default) { _ in
            completion(.photoLibrary)
        }
        let cancelButton = UIAlertAction(title: "cancel".localized(), style: .cancel)
        
        [cameraButton, libraryButton, cancelButton].forEach({ alert.addAction($0) })
        self.present(alert, animated: true)
    }
    
    private func fetchCurrentUser() {
        Task {
            do {
                let user = try await vm.fetchCurrentUser()
                subtitleLabel.text = user.username
                guard let imageUrl = user.profileImageUrl else {return}
                rightImage.kf.setImage(with: URL(string: imageUrl))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[.originalImage] as? UIImage {
            rightImage.image = pickedImage
            delegate?.setUserProfile(userData: .init(image: pickedImage, bio: bioInputField.text, link: linkInputField.text))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
