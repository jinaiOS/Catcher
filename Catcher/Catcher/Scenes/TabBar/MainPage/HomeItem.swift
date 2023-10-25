//
//  HomeItem.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

enum SectionName: String {
    case random
    case rank
    case near
    case new
    case pick
    
    var sectionID: String { rawValue }
}

struct Section: Hashable {
    let id: String
}

enum Item: Hashable {
    case random(UserInfo)
    case rank(UserInfo)
    case near(UserInfo)
    case new(UserInfo)
    case pick(UserInfo)
}
