//
//  UserImageView .swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 14.07.24.
//
import UIKit

class UserImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        image = UIImage(named: "userIcon")
        //contentMode = .scaleAspectFit
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
