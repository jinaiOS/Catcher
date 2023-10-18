//
//  MainPageViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

final class MainPageViewModel {
    
    func getSectionTitle(section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "이번 주 랭킹"
        case 2:
            return "내 근처 유저"
        case 3:
            return "신규 유저"
        case 4:
            return "찜한 유저"
        default:
            return nil
        }
    }
    
    let randomItems = [
        Item.random(HomeItem(imageUrl: "",
                             name: "랜덤 생성",
                             rank: "1")),
        Item.random(HomeItem(imageUrl: "",
                             name: "랜덤 생성",
                             rank: "2")),
        Item.random(HomeItem(imageUrl: "",
                             name: "랜덤 생성",
                             rank: "3")),
    ]
    
    let rankItems = [
        Item.rank(HomeItem(imageUrl: "",
                             name: "샘플1",
                             rank: "1")),
        Item.rank(HomeItem(imageUrl: "",
                             name: "샘플2",
                             rank: "2")),
        Item.rank(HomeItem(imageUrl: "",
                             name: "샘플3",
                             rank: "3")),
        Item.rank(HomeItem(imageUrl: "",
                             name: "샘플4",
                             rank: "4")),
        Item.rank(HomeItem(imageUrl: "",
                             name: "샘플5",
                             rank: "5"))
    ]
    
    let nearItems = [
        Item.near(HomeItem(imageUrl: "",
                             name: "샘플1",
                             rank: "1")),
        Item.near(HomeItem(imageUrl: "",
                             name: "샘플2",
                             rank: "2")),
        Item.near(HomeItem(imageUrl: "",
                             name: "샘플3",
                             rank: "3")),
        Item.near(HomeItem(imageUrl: "",
                             name: "샘플4",
                             rank: "4")),
        Item.near(HomeItem(imageUrl: "",
                             name: "샘플5",
                             rank: "5"))
    ]
    
    let newItems = [
        Item.new(HomeItem(imageUrl: "",
                             name: "샘플1",
                             rank: "1")),
        Item.new(HomeItem(imageUrl: "",
                             name: "샘플2",
                             rank: "2")),
        Item.new(HomeItem(imageUrl: "",
                             name: "샘플3",
                             rank: "3")),
        Item.new(HomeItem(imageUrl: "",
                             name: "샘플4",
                             rank: "4")),
        Item.new(HomeItem(imageUrl: "",
                             name: "샘플5",
                             rank: "5"))
    ]
    
    let pickItems = [
        Item.pick(HomeItem(imageUrl: "",
                             name: "샘플1",
                             rank: "1")),
        Item.pick(HomeItem(imageUrl: "",
                             name: "샘플2",
                             rank: "2")),
        Item.pick(HomeItem(imageUrl: "",
                             name: "샘플3",
                             rank: "3")),
        Item.pick(HomeItem(imageUrl: "",
                             name: "샘플4",
                             rank: "4")),
        Item.pick(HomeItem(imageUrl: "",
                             name: "샘플5",
                             rank: "5"))
    ]
    
}
