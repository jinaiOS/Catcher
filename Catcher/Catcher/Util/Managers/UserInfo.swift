//
//  UserInfo.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

struct UserInfo {
    let uid: String
    let nickName: String
    let profileUrl: String
    let location: String
    let height: Int
    let body: String
    let education: String
    let drinking: String
    let smoking: Bool
    var pick: [UserInfo]? = []
}
