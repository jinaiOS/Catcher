//
//  ConversationsModels.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
