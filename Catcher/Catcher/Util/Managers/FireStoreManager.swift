//
//  FireStoreManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import FirebaseFirestore

enum FireStoreError: Error {
    case canNotConvert
    case missingUID
    case deleteFail
    case noUIDList
    case noNearPath
}

final class FireStoreManager {
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()
    private let userInfoPath = "userInfo"
    private let nearUserPath = "location"
    private let itemCount: Int = 9
    let uid: String?
    
    private init(uid: String? = FirebaseManager().getUID) {
        self.uid = uid
    }
}

extension FireStoreManager {
    /// 닉네임 중복 확인
    func nickNamePass(nickName: String) async -> (Bool?, Error?) {
        let docRef = db.collection(userInfoPath)
            .whereField(Data.nickName.key, isEqualTo: nickName)
        do {
            if (try await docRef.getDocuments().documents.first?.data()) != nil {
                return (false, nil)
            }
            return (true, nil)
        } catch {
            return(nil, error)
        }
    }
}

extension FireStoreManager {
    func setUserInfo(data: UserInfo) async -> Error? {
        guard let uid = uid else { return FireStoreError.missingUID }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.setData(
                encodingValue(data: data)
            )
            return nil
        } catch {
            return error
        }
    }
}

extension FireStoreManager {
    func fetchRandomUser() async -> (result: [UserInfo]?, error: Error?) {
        let docRef = db.collection(userInfoPath)
        do {
            let document = try await docRef.getDocuments()
            let userInfo = document.documents.map { $0.data() }
            
            let shuffledArray = userInfo
                .randomElements(count: itemCount)
                .shuffleArray(userInfo)
                .compactMap {
                    decodingValue(data: $0)
                }
            return (shuffledArray, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchPickUsers() async -> (result: [UserInfo]?, error: Error?) {
        let result = await fetchMyPickUsersUID()
        if let error = result.error {
            return (nil, error)
        }
        guard let uidList = result.result else {
            return (nil, FireStoreError.noUIDList)
        }
        let userList = await groupTaskForFetchUsers(uidList: uidList)
        return (userList, nil)
    }
    
    func fetchUserInfo(uuid: String) async -> (result: UserInfo?, error: Error?) {
        let docRef = db.collection(userInfoPath).document(uuid)
        do {
            let document = try await docRef.getDocument()
            let userInfo = decodingValue(data: document.data())
            return (userInfo, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchRanking() async -> (result: [UserInfo]?, error: Error?) {
        let docRef = db.collection(userInfoPath)
            .order(by: Data.score.key, descending: true)
            .limit(to: itemCount)
        do {
            let document = try await docRef.getDocuments()
            let userInfoList = document.documents.map {
                $0.data()
            }.compactMap {
                decodingValue(data: $0)
            }
            return (userInfoList, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchNewestUser() async -> (result: [UserInfo]?, error: Error?) {
        do {
            let querySnapshot = try await db.collection(userInfoPath)
                .whereField(Data.register.key, isLessThan: Date())
                .limit(to: itemCount)
                .getDocuments()
            let userInfoList = querySnapshot.documents.compactMap { snapshot in
                decodingValue(data: snapshot.data())
            }
            return (userInfoList, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchNearUser() async -> (result: [UserInfo]?, error: Error?) {
        // 현재 저장된 나의 위치 데이터가 유실되었을 때 메인에 정보를 보이게 하기 위해 의도적으로 사용
        let location: String = UserDefaults.standard.string(forKey: nearUserPath) ?? ""
        
        do {
            let querySnapshot = try await db.collection(userInfoPath)
                .whereField(nearUserPath, isEqualTo: location)
                .getDocuments()
            let userInfoList = querySnapshot.documents.compactMap { snapshot in
                decodingValue(data: snapshot.data())
            }
            return (userInfoList, nil)
        } catch {
            return (nil, error)
        }
    }
}

extension FireStoreManager {
    func updatePickUser(uuid: String) async -> Error? {
        guard let uid = uid else { return FireStoreError.missingUID }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.updateData([
                Data.pick.key: FieldValue.arrayUnion([uuid])
            ])
            return nil
        } catch {
            return error
        }
    }
}

extension FireStoreManager {
    func deleteUserInfo() async -> Error? {
        guard let uid = uid else { return FireStoreError.deleteFail }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.delete()
            return nil
        } catch {
            return error
        }
    }
    
    func deletePickUser(uuid: String) async -> Error? {
        guard let uid = uid else { return FireStoreError.missingUID }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.updateData([
                Data.pick.key: FieldValue.arrayRemove([uuid])
            ])
            return nil
        } catch {
            return error
        }
    }
}

private extension FireStoreManager {
    func fetchMyPickUsersUID() async -> (result: [String]?, error: Error?) {
        guard let uid = uid else { return (nil, FireStoreError.missingUID) }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            let document = try await docRef.getDocument()
            let pickUsers = document.data()?[Data.pick.key] as? [String]
            return (pickUsers, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func groupTaskForFetchUsers(uidList: [String]) async -> [UserInfo] {
        let datas = await withTaskGroup(of: UserInfo?.self) { group in
            for uid in uidList {
                group.addTask {
                    let data = await self.fetchUserInfo(uuid: uid)
                    if let error = data.error {
                        CommonUtil.print(output:"error: \(error.localizedDescription)")
                        return nil
                    }
                    return data.result
                }
            }
            var dataList: [UserInfo?] = []
            for await userInfo in group {
                dataList.append(userInfo)
            }
            return dataList.compactMap { $0 }
        }
        return datas
    }
}

private extension FireStoreManager {
    enum Data: String {
        case uid
        case sex
        case birth
        case nickName
        case location
        case height
        case body
        case education
        case drinking
        case smoking
        case register
        case score
        case pick
        
        var key: String { rawValue }
    }
}

private extension FireStoreManager {
    func encodingValue(data: UserInfo) -> [String: Any] {
        [
            Data.uid.key: data.uid,
            Data.sex.key: data.sex,
            Data.birth.key: data.birth,
            Data.nickName.key: data.nickName,
            Data.location.key: data.location,
            Data.height.key: data.height,
            Data.body.key: data.body,
            Data.education.key: data.education,
            Data.drinking.key: data.drinking,
            Data.smoking.key: data.smoking,
            Data.register.key: data.register,
            Data.score.key: data.score,
            Data.pick.key: data.pick ?? []
        ]
    }
    
    func decodingValue(data: [String: Any]?) -> UserInfo? {
        guard let data = data else {
            return nil
        }
        return UserInfo(
            uid: data[Data.uid.key] as? String ?? "",
            sex: data[Data.sex.key] as? String ?? "",
            birth: (data[Data.birth.key] as? Timestamp)?.dateValue() ?? Date(),
            nickName: data[Data.nickName.key] as? String ?? "",
            location: data[Data.location.key] as? String ?? "",
            height: data[Data.height.key] as? Int ?? -1,
            body: data[Data.body.key] as? String ?? "",
            education: data[Data.education.key] as? String ?? "",
            drinking: data[Data.drinking.key] as? String ?? "",
            smoking: data[Data.smoking.key] as? Bool ?? false,
            register: data[Data.register.key] as? Date ?? Date(),
            score: data[Data.score.key] as? Int ?? 0,
            pick: data[Data.pick.key] as? [String] ?? []
        )
    }
}
