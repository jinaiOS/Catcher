//
//  HomeItem.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

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
    let imageUrl: String
    let name: String
    let rank: String
    
    init(imageUrl: String, name: String, rank: String) {
        self.imageUrl = imageUrl
        self.name = name
        self.rank = rank
    }
}
