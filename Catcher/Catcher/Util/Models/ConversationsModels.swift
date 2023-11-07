//
//  ConversationsModels.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation

enum ConversationKind: String {
    case Text = "text"
    case Photo = "photo"
    case Video = "video"
    case Location = "location"
}

struct Conversation {
    var name: String
    let senderUid: String
    let kind: ConversationKind
    let message: String
    let date: String
    let isRead: Bool
    var otherUserUid: String
}
