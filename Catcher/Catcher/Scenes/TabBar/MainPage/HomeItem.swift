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
    case random(HomeItem)
    case rank(HomeItem)
    case near(HomeItem)
    case new(HomeItem)
    case pick(HomeItem)
}

struct HomeItem: Hashable {
    let info: UserInfo
    
    init(info: UserInfo) {
        self.info = info
    }
    
    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        return lhs.info.ID == rhs.info.ID && lhs.info.ID == rhs.info.ID
    }
}
