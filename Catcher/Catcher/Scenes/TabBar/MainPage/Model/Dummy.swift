//
//  Dummy.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

fileprivate var dummyUser: UserInfo {
    UserInfo(uid: UUID().uuidString, sex: "", birth: Date(),
             nickName: "", location: "", height: 0, mbti: "", introduction: "")
}

fileprivate let dummyRandom = [Item.random(dummyUser), Item.random(dummyUser), Item.random(dummyUser),
                               Item.random(dummyUser), Item.random(dummyUser), Item.random(dummyUser)]
fileprivate let dummyRank = [Item.rank(dummyUser), Item.rank(dummyUser), Item.rank(dummyUser),
                             Item.rank(dummyUser), Item.rank(dummyUser), Item.rank(dummyUser)]
fileprivate let dummyNew = [Item.new(dummyUser), Item.new(dummyUser), Item.new(dummyUser),
                            Item.new(dummyUser), Item.new(dummyUser), Item.new(dummyUser)]
fileprivate let dummyNear = [Item.near(dummyUser), Item.near(dummyUser), Item.near(dummyUser),
                             Item.near(dummyUser), Item.near(dummyUser), Item.near(dummyUser)]
fileprivate let dummyPick = [Item.pick(dummyUser), Item.pick(dummyUser), Item.pick(dummyUser),
                             Item.pick(dummyUser), Item.pick(dummyUser), Item.pick(dummyUser)]
let DummyData = (dummyRandom, dummyRank, dummyNew, dummyNear, dummyPick)
