//
//  ConversationsModels.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation

struct Conversation {
    var name: String
    let senderUid: String
    let message: String
    let date: String
    let isRead: Bool
    var otherUserUid: String
}
