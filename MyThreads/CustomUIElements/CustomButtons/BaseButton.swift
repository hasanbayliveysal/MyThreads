//
//  BaseButton.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class BaseButton: UIButton {
    
    private func setup() {
        layer.cornerRadius = 12
        backgroundColor = .black.withAlphaComponent(0.9)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BlackTintButton: UIButton {
    private func setup() {
        tintColor = .black
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WhiteBackgroundButton: UIButton {
    private func setup() {
       layer.cornerRadius = 8
       layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
       backgroundColor = .white
       setTitle("follow".localized(), for: .normal)
       setTitleColor(.black, for: .normal)
       layer.borderWidth = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
