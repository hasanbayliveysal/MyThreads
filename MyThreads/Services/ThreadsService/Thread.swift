//
//  Thread.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 13.07.24.
//

import Foundation

struct Thread: Codable {
    let id: String
    let author: String
    let thread: String
    let time: Date
    var likedBy: [String] = []
    var comments: [Comment] = []

    var formattedTime: String {
        let interval = Date().timeIntervalSince(time)
        return Thread.formatTimeInterval(interval)
    }

    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days / 7
        let months = weeks / 4

        if months > 0 {
            return "\(months)m"
        } else if weeks > 0 {
            return "\(weeks)w"
        } else if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }

    struct Comment: Codable {
        let author: String
        let title: String
        let time: Date

        var formattedTime: String {
            let interval = Date().timeIntervalSince(time)
            return Thread.formatTimeInterval(interval)
        }
    }
}
