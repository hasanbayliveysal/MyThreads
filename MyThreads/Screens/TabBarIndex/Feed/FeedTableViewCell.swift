//
//  FeedTableViewCell.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 03.07.24.
//

import UIKit
import Kingfisher
import FirebaseAuth

class FeedTableViewCell: UITableViewCell {
    var likeButtonTapped: ((Bool) -> Void)?
    var commentButtonTapped: (() -> Void)?
    var threeDotButtonTapped: (()->Void)?
    
    private var likesCount: Int = 0
    private var isLiked: Bool = false
    private let currentUser = Auth.auth().currentUser
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 16
        return stackView
    }()
    
    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()
    
    private var actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 16
        return stackView
    }()
    
    private var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()
    
    private var profileImage: UserImageView = {
        let image = UserImageView(frame: .zero)
        return image
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private var postedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black.withAlphaComponent(0.2)
        return label
    }()
    
    private var threeDotButton: BlackTintButton = {
        let button = BlackTintButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    private var likeButton: BlackTintButton = {
        let button = BlackTintButton()
        button.setImage(UIImage(named: "like"), for: .normal)
   
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private var commentButton: BlackTintButton = {
        let button = BlackTintButton()
        button.setImage(UIImage(named: "message"), for: .normal)
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private var repostButton: BlackTintButton = {
        let button = BlackTintButton()
        button.setImage(UIImage(named: "repost"), for: .normal)
        return button
    }()
    
    private var sendButton: BlackTintButton = {
        let button = BlackTintButton()
        button.setImage(UIImage(named: "send"), for: .normal)
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(mainStackView)
        contentView.addSubview(actionsStackView)
        [timeLabel, threeDotButton]
            .forEach({rightStackView.addArrangedSubview($0)})
        [likeButton, likeCountLabel, commentButton, commentCountLabel, repostButton, sendButton]
            .forEach({actionsStackView.addArrangedSubview($0)})
        [usernameLabel, postedLabel]
            .forEach({verticalStackView.addArrangedSubview($0)})
        [profileImage, verticalStackView, rightStackView]
            .forEach({mainStackView.addArrangedSubview($0)})
        setupConstraints()
      //  verticalStackView.setCustomSpacing(20, after: postedLabel)
        actionsStackView.setCustomSpacing(4, after: likeButton)
        actionsStackView.setCustomSpacing(4, after: commentButton)
        
        likeButton.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action:  #selector(handleCommentButtonTapped), for: .touchUpInside)
        threeDotButton.addTarget(self, action:  #selector(handleThreeDotButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 24
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        actionsStackView.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom).offset(8)
            make.leading.equalTo(contentView.snp.leading).inset(72)
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
        
        profileImage.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
    
    func configure(with thread: Thread, imageLoadedCompletion: @escaping () -> Void) {
        isLiked = false
        profileImage.image =  UIImage(named: "userIcon")
        guard let userId = currentUser?.uid else {return}
        Task {
            do {
                let user = try await getAuthor(by: thread.author)
                usernameLabel.text = user.username
                
                await MainActor.run(body: {
                    self.postedLabel.text = thread.thread
                    self.timeLabel.text = thread.formattedTime
                    self.likeCountLabel.text = "\(thread.likedBy.count)"
                    self.commentCountLabel.text = "\(thread.comments.count)"
                    self.isLiked = thread.likedBy.contains(userId)
                    self.likesCount = thread.likedBy.count
                })
                guard let urlString = user.profileImageUrl else {
                    imageLoadedCompletion()
                    return
                }
                self.profileImage.kf.setImage(with: URL(string: urlString), completionHandler: { result in
                    imageLoadedCompletion()
                })
                if !self.isLiked {
                    self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                    self.likeCountLabel.textColor = .black
                } else {
                    self.likeButton.setImage(UIImage(named: "heart.fill"), for: .normal)
                    self.likeCountLabel.textColor = .red
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getAuthor(by id: String) async throws -> User {
        return try await UserService.shared.fetchUserByID(with: id)
    }
    
    
    @objc private func handleLikeButtonTapped() {
        if isLiked {
            likesCount -= 1
            likeCountLabel.text = "\(likesCount)"
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            likeCountLabel.textColor = .black
        } else {
            likesCount += 1
            likeCountLabel.text = "\(likesCount)"
            likeButton.setImage(UIImage(named: "heart.fill"), for: .normal)
            likeCountLabel.textColor = .red
        }
        isLiked.toggle()
        likeButtonTapped?(isLiked)
    }
    
    @objc
    private func handleCommentButtonTapped() {
        commentButtonTapped?()
    }
    
    @objc
    private func handleThreeDotButtonTapped() {
        threeDotButtonTapped?()
    }
}


