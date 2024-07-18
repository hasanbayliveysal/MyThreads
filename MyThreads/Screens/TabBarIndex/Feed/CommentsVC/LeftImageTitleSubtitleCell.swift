//
//  LeftImageTitleSubtitleCell.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 17.07.24.
//

import UIKit

class LeftImageTitleSubtitleCell: UITableViewCell {
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
        [timeLabel, threeDotButton]
            .forEach({rightStackView.addArrangedSubview($0)})
        [usernameLabel, postedLabel]
            .forEach({verticalStackView.addArrangedSubview($0)})
        [profileImage, verticalStackView, rightStackView]
            .forEach({mainStackView.addArrangedSubview($0)})
        setupConstraints()
      
    }
    
    private func setupConstraints() {
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 18
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        profileImage.snp.makeConstraints { make in
            make.size.equalTo(36)
        }
    }
    
    func configure(with item: Thread.Comment) {
        Task {
            do {
                let user = try await getUserByID(id: item.author)
                usernameLabel.text = user.username
                await MainActor.run(body: {
                    postedLabel.text   = item.title
                    timeLabel.text     = item.formattedTime
                })
                guard let urlString = user.profileImageUrl else {return}
                profileImage.kf.setImage(with: URL(string: urlString))
            }
        }
    }
    
    func getUserByID(id: String) async throws -> User {
        return try await UserService.shared.fetchUserByID(with: id)
    }
   
}
