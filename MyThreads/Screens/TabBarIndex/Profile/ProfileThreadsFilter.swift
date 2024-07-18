//
//  ProfileThreadsFilter.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 04.07.24.
//

import Foundation

enum ProfileThreadsFilter: Int, CaseIterable {
    case threads
    case replies
    
    var title: String {
        switch self {
        case .replies:
            return "Replies"
        case .threads:
            return "Threads"
        }
    }
}
