//
//  User.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 05.07.24.
//

import Foundation

struct User: Codable {
    let id: String
    let fullname: String
    let email: String
    let username: String
    var profileImageUrl: String?
    var bio: String?
    let isAccountPrivate: Bool
    var followerIDs: [String] = []
    var followingIDs: [String] = []
}
