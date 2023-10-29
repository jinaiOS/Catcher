//
//  ConversationsModels.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation

struct Conversation {
    let name: String
    let senderUid: String
    let message: String
    let date: String
    let isRead: Bool
    let otherUserUid: String
}
