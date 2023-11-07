//
//  UserInfo.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

struct UserInfo: Hashable {
    let ID = UUID()
    
    let uid: String
    let sex: String
    let birth: Date
    var nickName: String
    var location: String
    var height: Int
    var mbti: String
    var introduction: String
    var register: Date = Date()
    var pick: [String]? = []
    var block: [String]? = []
    
    /// 찜 받은 개수로 랭킹 나타내기 위한 프로퍼티
    var heart: Int = 0
}
