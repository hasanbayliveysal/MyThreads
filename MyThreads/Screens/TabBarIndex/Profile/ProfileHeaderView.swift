//
//  ProfileHeaderView.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import UIKit
import Kingfisher

class ProfileHeaderView: UIView {
    
    private var selectedFilter: ProfileThreadsFilter = .threads {
        didSet {
            changeFilters()
            selected?(selectedFilter)
        }
    }
    var selected: ((ProfileThreadsFilter)->Void)?
    var userType: UserType = .CurrentUser
    
    private let mainStackView: VStack = {
        let stackView = VStack()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let titleSubtitleStackView: VStack = {
        let stackView = VStack()
        stackView.axis = .vertical
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let topStackView: HStack = {
        let stackView = HStack()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    let rightImage: UserImageView = {
        let image = UserImageView(frame: .zero)
        return image
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black.withAlphaComponent(0.3)
        return label
    }()
    
    private let bottomStackView: HStack = {
        let stackView = HStack()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    let editButton: WhiteBackgroundButton = {
        let button = WhiteBackgroundButton()
        button.setTitle("edit".localized(), for: .normal)
        return button
    }()
    
    private let shareButton: WhiteBackgroundButton = {
        let button = WhiteBackgroundButton()
        button.setTitle("share".localized(), for: .normal)
        return button
    }()
    
    private let bioStackView = HStack()
    private let followersStackView = HStack()
    
    private var filterStackView: HStack = {
        let stackView = HStack()
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
 
    private var threadsStackView: VStack = {
        let stackView = VStack()
        stackView.spacing = 8
        return stackView
    }()

    private var repliesStackView: VStack = {
        let stackView = VStack()
        stackView.spacing = 8
        return stackView
    }()

    private let threadsLabel: UILabel = {
        let label = UILabel()
        label.text = "Threads"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let repliesLabel: UILabel = {
        let label = UILabel()
        label.text = "Replies"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let threadsRectangleView: Rectangle = Rectangle()
    private let repliesRectangleView: Rectangle = Rectangle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        changeFilters()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainStackView)
        [titleLabel, subtitleLabel].forEach({titleSubtitleStackView.addArrangedSubview($0)})
        [titleSubtitleStackView, rightImage].forEach({topStackView.addArrangedSubview($0)})
        [editButton, shareButton].forEach({bottomStackView.addArrangedSubview($0)})
        [bioLabel, UIView()].forEach({bioStackView.addArrangedSubview($0)})
        [followersLabel, UIView()].forEach({followersStackView.addArrangedSubview($0)})
        [threadsLabel, threadsRectangleView].forEach({threadsStackView.addArrangedSubview($0)})
        [repliesLabel, repliesRectangleView].forEach({repliesStackView.addArrangedSubview($0)})
        [threadsStackView, repliesStackView].forEach({filterStackView.addArrangedSubview($0)})
        
        [topStackView,
         bioStackView,
         followersStackView,
         bottomStackView,
         filterStackView]
            .forEach({mainStackView.addArrangedSubview($0)})
        mainStackView.setCustomSpacing(40, after: bottomStackView)
        addTapGestureRecognizer()
        setupConstraints()
    }

    
    private func setupConstraints() {
        rightImage.clipsToBounds = true
        rightImage.layer.cornerRadius = 32
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rightImage.snp.makeConstraints { make in
            make.size.equalTo(64)
        }
    }
    
    private  func addTapGestureRecognizer() {
        let tapThreads = CustomTapGestureRecognizer(target: self, action: #selector(didChangeFilter(_ :)))
        tapThreads.identifier = 0
        let tapReplies = CustomTapGestureRecognizer(target: self, action: #selector(didChangeFilter(_ :)))
        tapReplies.identifier = 1
        threadsStackView.addGestureRecognizer(tapThreads)
        repliesStackView.addGestureRecognizer(tapReplies)
    }
    
    private func changeFilters() {
        switch selectedFilter {
        case .threads:
            UIView.animate(withDuration: 0.3) {
                self.threadsLabel.font = .systemFont(ofSize: 12, weight: .semibold)
                self.repliesLabel.font = .systemFont(ofSize: 12, weight: .regular)
                self.threadsRectangleView.backgroundColor = .black
                self.repliesRectangleView.backgroundColor = .clear
            }
        case .replies:
            UIView.animate(withDuration: 0.3) {
                self.repliesLabel.font = .systemFont(ofSize: 12, weight: .semibold)
                self.threadsLabel.font = .systemFont(ofSize: 12, weight: .regular)
                self.repliesRectangleView.backgroundColor = .black
                self.threadsRectangleView.backgroundColor = .clear
            }
        }
    }

    func configure(with item: Item, and userType: UserType) {
        self.userType = userType
        switch userType {
        case .GuestUser(let isFollowing):
            shareButton.isHidden = true
            editButton.setTitle(isFollowing ? "following".localized() :
                                    "follow".localized(),
                                for: .normal)
            editButton.backgroundColor = isFollowing ? .white : .black
            editButton.setTitleColor(isFollowing ? .black : .white, for: .normal)
        case .CurrentUser :
            shareButton.isHidden = false
            editButton.setTitle("edit".localized(), for: .normal)
        }
        titleLabel.text = item.name
        subtitleLabel.text = item.username
        bioLabel.text = item.bio
        bioLabel.isHidden = (item.bio == nil)
        followersLabel.text = ([0, 1].contains(item.followersCount)) ?
        "\(item.followersCount) follower" :
        "\(item.followersCount) followers"
        guard let image = item.image,
              let imageUrl = URL(string: image) else {
            return
        }
        rightImage.kf.setImage(with: imageUrl)
    }
}


extension ProfileHeaderView {
    @objc
    func didChangeFilter(_ sender: CustomTapGestureRecognizer) {
        guard let identifier = sender.identifier  else {
            return
        }
        
        switch identifier {
        case 0:
            selectedFilter = .threads
        case 1:
            selectedFilter = .replies
        default:
            break
        }
    }
}


extension ProfileHeaderView {
    
    struct Item {
        let name: String
        let username: String
        let image: String?
        let bio: String?
        let followersCount: Int
    }
    
    enum UserType: Equatable {
        case CurrentUser
        case GuestUser(isFollowing: Bool)
    }
    
}


extension ProfileHeaderView {
    func addTargetEditButton(target: Any?, action: Selector, for event: UIControl.Event) {
        editButton.addTarget(target, action: action, for: event)
    }
    func addTargetShareButton(target: Any?, action: Selector, for event: UIControl.Event) {
        shareButton.addTarget(target, action: action, for: event)
    }
}
