//
//  CustomUIViews.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import UIKit

class Rectangle: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        backgroundColor = .black.withAlphaComponent(0.1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

