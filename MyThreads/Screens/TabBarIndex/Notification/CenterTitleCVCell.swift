//
//  CenterTitleCVCell.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 18.07.24.
//

import UIKit

class CenterTitleCVCell: UICollectionViewCell {
    
    private let containerView: UIView  = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel:    UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.addSubview(titleLabel)
        contentView.addSubview(containerView)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    func setSelected(_ selected: Bool) {
        containerView.backgroundColor = selected ? .black : .white
        titleLabel.textColor = selected ? .white : .black
    }
}


enum Activities: String{
    case Follow = "follows"
    case Replies = "replies"
    case Mentions = "mentions"
}
