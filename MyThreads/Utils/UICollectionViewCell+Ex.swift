//
//  UICollectionViewCell+Ex.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 03.07.24.
//

import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}


extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
