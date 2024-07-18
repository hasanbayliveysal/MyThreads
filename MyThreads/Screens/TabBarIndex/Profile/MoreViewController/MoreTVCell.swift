//
//  MoreTVCell.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 15.07.24.
//

import UIKit

class MoreTVCell: UITableViewCell {
    
    private var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var stackView: HStack = {
        let hStack = HStack()
        hStack.spacing = 8
        hStack.distribution = .fillProportionally
        hStack.alignment = .center
        return hStack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI () {
        selectionStyle = .none
        contentView.addSubview(stackView)
        [leftImageView,titleLabel, UIView()].forEach({stackView.addArrangedSubview($0)})
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges).inset(8)
        }
        
        leftImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
        }
    }
    
    func configure(with item: MoreVCElemets) {
        titleLabel.text = item.rawValue.localized()
        leftImageView.image = UIImage(systemName: item.image)
    }
    
}


enum MoreVCElemets: String {
   case liked
   case language
   case help
   case about
   
   var image: String {
       switch self {
       case .about:
           return "i.circle"
       case .help:
           return "questionmark.circle"
       case .language:
           return "globe"
       case .liked:
           return "heart"
       }
   }
}
