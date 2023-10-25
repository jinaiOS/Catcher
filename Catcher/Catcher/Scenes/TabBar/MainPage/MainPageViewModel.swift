//
//  MainPageViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import Combine

final class MainPageViewModel {
    private let storeManager = FireStoreManager.shared
    let mainSubject = CurrentValueSubject<MainItems, Never>(.init(data: ([], [], [], [], [])))
}

extension MainPageViewModel {
    func getSectionTitle(section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "평점 높은 유저"
        case 2:
            return "나의 동네 유저"
        case 3:
            return "신규 유저"
        case 4:
            return "찜한 유저"
        default:
            return nil
        }
    }
    
    func fetchMainPageData() {
        guard let date = oneMonthAgo else { return }
        Task {
            async let random = storeManager.fetchRandomUser()
            async let rank = storeManager.fetchRanking()
            async let near = storeManager.fetchNearUser()
            async let pick = storeManager.fetchPickUsers()
            async let new = storeManager.fetchNewestUser(date: date)
            
            let randomResult = await random
            let rankResult = await rank
            let nearResult = await near
            let pickResult = await pick
            let newResult = await new
            
            if let randomError = randomResult.1,
               let rankError = rankResult.1,
               let nearError = nearResult.1,
               let pickError = pickResult.1,
               let newError = newResult.1 {
                print(randomError.localizedDescription)
                print(rankError.localizedDescription)
                print(nearError.localizedDescription)
                print(pickError.localizedDescription)
                print(newError.localizedDescription)
                return
            }
            guard let randomUser = randomResult.0,
                  let rankUser = rankResult.0,
                  let nearUser = nearResult.0,
                  let pickUser = pickResult.0,
                  let newUser = newResult.0 else { return }
            sendItems(data: (randomUser, rankUser, nearUser, pickUser, newUser))
        }
    }
    
    func userInfoFromItem(item: Item) -> UserInfo {
        switch item {
        case .random(let info):
            return info
        case .rank(let info):
            return info
        case .near(let info):
            return info
        case .new(let info):
            return info
        case .pick(let info):
            return info
        }
    }
}

private extension MainPageViewModel {
    var oneMonthAgo: Date? {
        let calendar = Calendar.current
        if let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) {
            return oneMonthAgo
        }
        return nil
    }
    
    func sendItems(data: ([UserInfo], [UserInfo], [UserInfo], [UserInfo], [UserInfo])) {
        let items = makeItems(data: (data.0, data.1, data.2, data.3, data.4))
        let data = MainItems(data: (items.0, items.1, items.2, items.3, items.4))
        mainSubject.send(data)
    }
    
    func makeItems(data: ([UserInfo], [UserInfo], [UserInfo], [UserInfo], [UserInfo])) -> ([Item], [Item], [Item], [Item], [Item]) {
        let randomItem = data.0.map {
            Item.random($0)
        }
        let rankItem = data.1.map {
            Item.rank($0)
        }
        let nearItem = data.2.map {
            Item.near($0)
        }
        let pickItem = data.3.map {
            Item.pick($0)
        }
        let newItem = data.4.map {
            Item.new($0)
        }
        return (randomItem, rankItem, nearItem, pickItem, newItem)
    }
}
