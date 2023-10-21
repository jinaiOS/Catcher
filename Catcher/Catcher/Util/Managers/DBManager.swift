//
//  DBManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import FirebaseDatabase

enum DBError: Error {
    case canNotConvert
    case missingUID
}

final class DBManager {
    static let shared = DBManager()
    private var ref = Database.database(url: REALTIME_DB_STORE_URL).reference()
    private var uid: String?
    
    private init() {
        uid = FirebaseManager().getUID
    }
}

private extension DBManager {
    enum Path: String {
        case userInfo
        case pick
        case newUser
        case ranking
        
        var path: String { rawValue }
    }
    
    enum Data: String {
        case uid
        case nikcName
        case profileUrl
        case location
        case height
        case body
        case education
        case drinking
        case smoking
        
        var key: String { rawValue }
    }
}

extension DBManager: UserInfoManager {
    func setUserInfo(data: UserInfo) {
        guard let uid = uid else { return }
        let value = encodingValue(data: data)
        ref.child(Path.userInfo.path).child(uid).setValue(value)
    }
    
    func fetchUserInfo(uid: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        ref.child(Path.userInfo.path).child(uid).getData { error, snapshot in
            self.errorHandling(completion: completion, error: error)
            let value = self.convertSnapshotToData(snapshot: snapshot, completion: completion)
            let result = self.decodingValue(data: value)
            completion(result, nil)
        }
    }
    
    /// 반드시 탈퇴할 때만 사용하세요!!!
    func deleteUserInfo() {
        guard let uid = uid else { return }
        ref.child(Path.userInfo.path).child(uid).removeValue()
    }
}

extension DBManager: PickManager {
    func setPickUser(userUID: String) {
        guard let uid = uid else { return }
        ref.child(Path.userInfo.path).child(uid).child(Path.pick.path).child(userUID).setValue("")
    }
    
    func fetchPickUser(completion: @escaping ([String]?, Error?) -> Void) {
        guard let uid = uid else {
            completion(nil, DBError.missingUID)
            return
        }
        ref.child(Path.userInfo.path).child(uid).child(Path.pick.path).getData { error, snapshot in
            self.errorHandling(completion: completion, error: error)
            let value = self.convertSnapshotToData(snapshot: snapshot, completion: completion)
            let strKeys = value?.keys.compactMap { $0 as String }
            completion(strKeys, nil)
        }
    }
    
    func deletePickUser(userUID: String) {
        guard let uid = uid else { return }
        ref.child(Path.userInfo.path).child(uid).child(Path.pick.path).child(userUID).removeValue()
    }
}

extension DBManager: NewestManager {
    func setNewUser(uid: String) {
        let date = Date().description
        ref.child(Path.newUser.path).child(uid).setValue(date)
    }
    
    func fetchNewUser(completion: @escaping ([String: Any]?, Error?) -> Void) {
        ref.child(Path.newUser.path).getData { error, snapshot in
            self.errorHandling(completion: completion, error: error)
            let value = self.convertSnapshotToData(snapshot: snapshot, completion: completion)
            completion(value, nil)
        }
    }
    
    func deleteNewUser(userUID: String) {
        ref.child(Path.newUser.path).child(userUID).removeValue()
    }
}

extension DBManager: RankingManager {
    func setRankingUser(uid: String, rank: Int) {
        ref.child(Path.ranking.path).child(uid).setValue(rank)
    }
    
    func fetchRanking(completion: @escaping ([String: Any]?, Error?) -> Void) {
        ref.child(Path.ranking.path).getData { error, snapshot in
            self.errorHandling(completion: completion, error: error)
            let value = self.convertSnapshotToData(snapshot: snapshot, completion: completion)
            completion(value, nil)
        }
    }
    
    func deleteRankingUser(userUID: String) {
        ref.child(Path.ranking.path).child(userUID).removeValue()
    }
}

private extension DBManager {
    func encodingValue(data: UserInfo) -> [String: Any] {
        [
            Data.uid.key: data.uid,
            Data.nikcName.key: data.nickName,
            Data.profileUrl.key: data.profileUrl,
            Data.location.key: data.location,
            Data.height.key: data.height,
            Data.body.key: data.body,
            Data.education.key: data.education,
            Data.drinking.key: data.drinking,
            Data.smoking.key: data.smoking
        ]
    }
    
    func decodingValue(data: [String: Any]?) -> UserInfo {
        UserInfo(
            uid: data?[Data.uid.key] as? String ?? "",
            nickName: data?[Data.nikcName.key] as? String ?? "익명",
            profileUrl: data?[Data.profileUrl.key] as? String ?? "",
            location: data?[Data.location.key] as? String ?? "",
            height: data?[Data.height.key] as? Int ?? -1,
            body: data?[Data.body.key] as? String ?? "",
            education: data?[Data.education.key] as? String ?? "",
            drinking: data?[Data.drinking.key] as? String ?? "",
            smoking: data?[Data.smoking.key] as? Bool ?? false
        )
    }
    
    func convertSnapshotToData<T>(snapshot: DataSnapshot?, completion: (T?, Error?) -> Void) -> [String: Any]? {
        guard let snapshot = snapshot?.value as? [String: Any] else {
            completion(nil, DBError.canNotConvert)
            return nil
        }
        return snapshot
    }
    
    func errorHandling<T>(completion: @escaping (T?, Error) -> Void, error: Error?) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            completion(nil, error)
        }
    }
}
