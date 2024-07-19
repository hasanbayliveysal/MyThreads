//
//  LeftImageTitleButtonCell.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import UIKit

class LeftImageTitleButtonCell: UITableViewCell {
    var isFollowingClousure: ((Bool) -> Void)? = nil
    var isFollowing: Bool = false
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        return stackView
    }()
    
    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private var leftImage: UserImageView = {
        let image = UserImageView(frame: .zero)
        return image
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    lazy var rightButton: WhiteBackgroundButton = {
        let button = WhiteBackgroundButton()
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
        [titleLabel,subtitleLabel].forEach({verticalStackView.addArrangedSubview($0)})
        [verticalStackView, rightButton].forEach({rightStackView.addArrangedSubview($0)})
        [leftImage,rightStackView].forEach({mainStackView.addArrangedSubview($0)})
        
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        setupConstraints()
    }
    
    private func setupConstraints() {
        leftImage.clipsToBounds = true
        leftImage.layer.cornerRadius = 24
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        rightButton.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(96)
        }
        
        leftImage.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
    
    func configure(with user: User, activity: Activities? = nil) {
        titleLabel.text = user.username
        subtitleLabel.text = user.fullname
        leftImage.image = nil
        if let imageUrlString = user.profileImageUrl,
           let imageUrl = URL(string: imageUrlString) {
            leftImage.kf.setImage(with: imageUrl)
        } else {
            leftImage.image = UIImage(named: "userIcon")
        }
        guard let activity else {return}
        switch activity {
        case .Follow :
            subtitleLabel.text = "followedyou".localized()
        case .Mentions :
            subtitleLabel.text = "likedthread".localized()
        case .Replies :
            subtitleLabel.text = "repliedthread".localized()
        }
        
    }
}


extension LeftImageTitleButtonCell {
    @objc
    func didTapRightButton() {
        isFollowing.toggle()
        isFollowingClousure?(isFollowing)
        isFollowing ? isFollowingg() : isNotFollowing()
    }
    
    func isFollowingg() {
        rightButton.setTitleColor(
            .black.withAlphaComponent(0.1),
            for: .normal)
        rightButton.setTitle(
            "following".localized(),
            for: .normal)
    }
    
    func isNotFollowing() {
        rightButton.setTitleColor(
            .black,
            for: .normal)
        rightButton.setTitle(
            "follow".localized(),
            for: .normal)
    }
    
    
}
