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
    let near: [Item]
    let pick: [Item]
    let new: [Item]
    
    init(data: ([Item], [Item], [Item], [Item], [Item])) {
        self.random = data.0
        self.rank = data.1
        self.near = data.2
        self.pick = data.3
        self.new = data.4
    }
}
