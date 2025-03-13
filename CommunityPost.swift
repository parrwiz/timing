//
//  CommunityPost.swift
//  Arkan
//
//  Created by mac on 2/3/25.
//

import Foundation

struct CommunityPost: Identifiable, Codable {
    let id: String
    let author: String
    let content: String
    let timestamp: Date
    var replies: [String]  // ✅ Now supports replies
    
    init(id: String = UUID().uuidString, author: String, content: String, timestamp: Date, replies: [String] = []) {
        self.id = id
        self.author = author
        self.content = content
        self.timestamp = timestamp
        self.replies = replies
    }
}
