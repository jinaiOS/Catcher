//
//  MainPageViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Combine
import Foundation

final class MainPageViewModel {
    private let storeManager = FireStoreManager.shared
    private let uid = FirebaseManager().getUID
    let mainSubject = CurrentValueSubject<MainItems, Never>(.init(data: DummyData))
    var myInfo: UserInfo?
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
            async let shutout = storeManager.fetchShutOutUser()
            
            let randomResult = await random
            let rankResult = await rank
            let newResult = await new
            let nearResult = await near
            let pickResult = await pick
            let shutoutResult = await shutout
            
            if let randomError = randomResult.error,
               let rankError = rankResult.error,
               let newError = newResult.error,
               let nearError = nearResult.error,
               let pickError = pickResult.error,
               let shutoutError = shutoutResult.error {
                CommonUtil.print(output: randomError.localizedDescription)
                CommonUtil.print(output: rankError.localizedDescription)
                CommonUtil.print(output: newError.localizedDescription)
                CommonUtil.print(output: nearError.localizedDescription)
                CommonUtil.print(output: pickError.localizedDescription)
                CommonUtil.print(output: shutoutError.localizedDescription)
                return
            }
            guard let randomUser = randomResult.result,
                  let rankUser = rankResult.result,
                  let newUser = newResult.result,
                  let nearUser = nearResult.result,
                  let pickUser = pickResult.result,
                  let shutoutUser = shutoutResult.result else { return }
            sendItems(data: (randomUser, rankUser, newUser, nearUser, pickUser, shutoutUser))
        }
    }
    
    func fetchMyInfo() {
        guard let uid = uid else { return }
        Task {
            let (result, error) = await storeManager.fetchUserInfo(uuid: uid)
            if let error {
                CommonUtil.print(output: error.localizedDescription)
                return
            }
            myInfo = result
        }
    }
}

extension MainPageViewModel {
    func getSectionTitle(section: Int) -> String? {
        switch section {
        case 0:
            return "Catcher"
        case 1:
            return "인기스타를 소개해요"
        case 2:
            return "뉴~ 진스가 아닌 뉴~ 피플"
        case 3:
            if mainSubject.value.near.isEmpty {
                return "당신이 투표한 유저"
            }
            return "당신의 동네에 이런 사람이?!"
        case 4:
            return "당신이 투표한 유저"
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
    
    func isBlockedUser(uid: String) -> Bool {
        guard let myInfo = myInfo,
              let blockList = myInfo.block else { return false }
        if blockList.contains(uid) {
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
    
    func sendItems(data: (random: [UserInfo], rank: [UserInfo], new: [UserInfo], near: [UserInfo], pick: [UserInfo], shutout: [String])) {
        let items = makeItems(data: (data.random, data.rank, data.new, data.near, data.pick, data.shutout))
        let data = MainItems(data: (items.random, items.rank, items.new, items.near, items.pick))
        mainSubject.send(data)
    }
    
    func makeItems(data: (random: [UserInfo], rank: [UserInfo], new: [UserInfo],
                          near: [UserInfo], pick: [UserInfo], shutout: [String])
    ) -> (random: [Item], rank: [Item], new: [Item], near: [Item], pick: [Item]) {
        func filterAndMap(items: [UserInfo], transform: (UserInfo) -> Item) -> [Item] {
            return items
                .filter { $0.uid != uid && !data.shutout.contains($0.uid) }
                .map { transform($0) }
        }
        let randomItem = filterAndMap(items: data.random, transform: Item.random)
        let rankItem = filterAndMap(items: data.rank, transform: Item.rank)
        let newItem = filterAndMap(items: data.new, transform: Item.new)
        let nearItem = filterAndMap(items: data.near, transform: Item.near)
        let pickItem = filterAndMap(items: data.pick, transform: Item.pick)
        
        return (randomItem, rankItem, newItem, nearItem, pickItem)
    }
}
