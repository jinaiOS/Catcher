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
    private let uid = FirebaseManager().getUID
    let mainSubject = CurrentValueSubject<MainItems, Never>(.init(data: DummyData))
}

extension MainPageViewModel {
    /// 모든 데이터 최신화
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
            if mainSubject.value.near.isEmpty {
                return "찜한 유저"
            }
            return "나의 동네 유저"
        case 4:
            return "찜한 유저"
        default:
            return nil
        }
    }
    
    func getSectionItems(section: Int) -> [Item]? {
        let items: [Item]
        let value = mainSubject.value
        
        switch section {
        case 0:
            items = mainSubject.value.random
        case 1:
            items = mainSubject.value.rank
        case 2:
            items = mainSubject.value.new
        case 3:
            if value.near.isEmpty {
                items = mainSubject.value.pick
                return items
            }
            items = mainSubject.value.near
            return items
        case 4:
            items = mainSubject.value.pick
        default:
            return nil
        }
        return items
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
        let randomItem = data.random
            .filter { $0.uid != uid }
            .map { Item.random($0) }
        let rankItem = data.rank
            .filter { $0.uid != uid }
            .map { Item.rank($0) }
        let newItem = data.new
            .filter { $0.uid != uid }
            .map { Item.new($0) }
        let nearItem = data.near
            .filter { $0.uid != uid }
            .map { Item.near($0) }
        let pickItem = data.pick
            .filter { $0.uid != uid }
            .map { Item.pick($0) }
        
        return (randomItem, rankItem, newItem, nearItem, pickItem)
    }
}
