import UIKit

protocol RepliesDelegate {
    func repliesDidChange()
}

final class CommentsVC: BaseViewController<CommentsVM> {
    var delegate: RepliesDelegate?
    private var mainStackView: VStack = {
        let stackView = VStack()
        return stackView
    }()
    
    private let repliesTV: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let bottomstackView: HStack = {
        let stackView = HStack()
        return stackView
    }()
    
    private let bottomView: CenterInputButtonView = {
        let view = CenterInputButtonView()
        view.backgroundColor = .white
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0.8
        effectView.isHidden = true
        return effectView
    }()
    
    private var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "replies".localized()
        setup()
        setupKeyboardNotifications()
    }
    
    private func setup() {
        fetchComments()
        repliesTV.register(LeftImageTitleSubtitleCell.self, forCellReuseIdentifier: LeftImageTitleSubtitleCell.identifier)
        repliesTV.dataSource = vm
        view.addSubview(repliesTV)
        view.addSubview(bottomView)
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupConstraints()
        
        vm.reloadTableView = {[weak self] in
            DispatchQueue.main.async {
                self?.repliesTV.reloadData()
            }
        }
        bottomView.postButtunTapped = { [weak self] postedText in
            guard let postedText else {
                self?.showAlert("error".localized(), "cannotbeempty".localized())
                return
            }
            self?.showLoading()
            Task {
                await self?.vm.addComment(postedText: postedText)
                DispatchQueue.main.async {
                    self?.fetchComments()
                    self?.repliesTV.reloadData()
                    self?.hideLoading()
                    self?.delegate?.repliesDidChange()
                }
            }
        }
    }
    
    private func setupConstraints() {
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        repliesTV.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top).offset(-16)
        }
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func fetchComments() {
        showLoading()
        Task {
            do {
                try await vm.getComment()
                hideLoading()
            } catch {
                self.showAlert("error".localized(), error.localizedDescription)
                hideLoading()
            }
        }
    }
    
    private func showLoading() {
        blurEffectView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        blurEffectView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.bottomView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(self.keyboardHeight + 8)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.bottomView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(8)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
