//
//  UserInfo.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

struct UserInfo {
    let uid: String
    let sex: String
    var nickName: String
    var location: String
    var height: Int
    var body: String
    var education: String
    var drinking: String
    var smoking: Bool
    var register: Date = Date()
    var score: Int
    var pick: [String]? = []
}
