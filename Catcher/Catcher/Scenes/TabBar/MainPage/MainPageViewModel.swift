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
    let mainSubject = CurrentValueSubject<MainItems, Never>(.init(data: DummyData))
}

extension MainPageViewModel {
    func getSectionTitle(section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "평점 높은 유저"
        case 2:
            return "신규 유저"
        case 3:
            return "나의 동네 유저"
        case 4:
            return "찜한 유저"
        default:
            return nil
        }
    }
    
    func fetchMainPageData() {
        Task {
            async let random = storeManager.fetchRandomUser()
            async let rank = storeManager.fetchRanking()
            async let new = storeManager.fetchNewestUser()
            async let near = storeManager.fetchNearUser()
            async let pick = storeManager.fetchPickUsers()
            
            let randomResult = await random
            let rankResult = await rank
            let newResult = await new
            let nearResult = await near
            let pickResult = await pick
            
            if let randomError = randomResult.error,
               let rankError = rankResult.error,
               let newError = newResult.error,
               let nearError = nearResult.error,
               let pickError = pickResult.error {
                print(randomError.localizedDescription)
                print(rankError.localizedDescription)
                print(newError.localizedDescription)
                print(nearError.localizedDescription)
                print(pickError.localizedDescription)
                return
            }
            guard let randomUser = randomResult.result,
                  let rankUser = rankResult.result,
                  let newUser = newResult.result,
                  let nearUser = nearResult.result,
                  let pickUser = pickResult.result else { return }
            sendItems(data: (randomUser, rankUser, newUser, nearUser, pickUser))
        }
    }
    
    func isPickedUser(info: UserInfo) -> Bool {
        let uids = fetchPickedUser.map { $0.uid }
        if uids.contains(info.uid) {
            return true
        }
        return false
    }
    
    func userInfoFromItem(item: Item) -> UserInfo {
        switch item {
        case .random(let info):
            return info
        case .rank(let info):
            return info
        case .new(let info):
            return info
        case .near(let info):
            return info
        case .pick(let info):
            return info
        }
    }
    
    func updatePickUser(info: [UserInfo]) {
        let items = info.map {
            Item.pick($0)
        }
        var currentValue = mainSubject.value
        currentValue.pick = items
        mainSubject.send(currentValue)
    }
}

private extension MainPageViewModel {
    var fetchPickedUser: [UserInfo] {
        let item = mainSubject.value.pick
        let pickedUsers = item.map {
            userInfoFromItem(item: $0)
        }
        return pickedUsers
    }
    
    func sendItems(data: (random: [UserInfo], rank: [UserInfo], new: [UserInfo], near: [UserInfo], pick: [UserInfo])) {
        let items = makeItems(data: (data.random, data.rank, data.new, data.near, data.pick))
        let data = MainItems(data: (items.random, items.rank, items.new, items.near, items.pick))
        mainSubject.send(data)
    }
    
    func makeItems(data: (random: [UserInfo], rank: [UserInfo],
                          new: [UserInfo], near: [UserInfo], pick: [UserInfo])
    ) -> (random: [Item], rank: [Item], new: [Item], near: [Item], pick: [Item]) {
        let randomItem = data.random.map {
            Item.random($0)
        }
        let rankItem = data.rank.map {
            Item.rank($0)
        }
        let newItem = data.new.map {
            Item.new($0)
        }
        let nearItem = data.near.map {
            Item.near($0)
        }
        let pickItem = data.pick.map {
            Item.pick($0)
        }
        return (randomItem, rankItem, newItem, nearItem, pickItem)
    }
}
