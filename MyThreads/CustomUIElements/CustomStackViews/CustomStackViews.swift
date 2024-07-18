//
//  CustomStackViews.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import UIKit

class HStack: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .equalSpacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class VStack: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
