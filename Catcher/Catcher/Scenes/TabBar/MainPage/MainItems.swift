//
//  MainItems.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

struct MainItems {
    let random: [Item]
    let rank: [Item]
    let new: [Item]
    let near: [Item]
    var pick: [Item]
    
    init(data: (random: [Item], rank: [Item], new: [Item], near: [Item], pick: [Item])) {
        self.random = data.random
        self.rank = data.rank
        self.new = data.new
        self.near = data.near
        self.pick = data.pick
    }
}
