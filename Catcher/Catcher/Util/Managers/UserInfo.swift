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
    var body: String
    var education: String
    var drinking: String
    var smoking: Bool
    var register: Date = Date()
    var score: Int = 0
    var pick: [String]? = []
    var block: [String]? = []
}
