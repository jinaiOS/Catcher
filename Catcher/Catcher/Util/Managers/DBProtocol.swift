//
//  DBProtocol.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

protocol UserInfoManager {
    func setUserInfo(data: UserInfo)
    func fetchUserInfo(uid: String, completion: @escaping (UserInfo?, Error?) -> Void)
    /// 반드시 탈퇴할 때만 사용하세요!!!
    func deleteUserInfo()
}

protocol PickManager {
    func setPickUser(userUID: String)
    func fetchPickUser(completion: @escaping ([String]?, Error?) -> Void)
    func deletePickUser(userUID: String)
}

protocol NewestManager {
    func setNewUser(uid: String)
    func fetchNewUser(completion: @escaping ([String: Any]?, Error?) -> Void)
    func deleteNewUser(userUID: String)
}

protocol RankingManager {
    func setRankingUser(uid: String, rank: Int)
    func fetchRanking(completion: @escaping ([String: Any]?, Error?) -> Void)
    func deleteRankingUser(userUID: String)
}
