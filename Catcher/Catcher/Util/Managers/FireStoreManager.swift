//
//  FireStoreManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import FirebaseFirestore
import Foundation

final class FireStoreManager {
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()
    private let userInfoPath = "userInfo"
    private let nearUserPath = "location"
    private let pickerPath = "picker"
    private let shutoutPath = "shutout"
    private let reportPath = "report"
    private let askPath = "ask"
    private let fcmTokenPath = "fcmToken"
    private let itemCount: Int = 20
    
    private init() { }
    
    enum FireStoreError: Error {
        case canNotConvert
        case missingUID
        case deleteFail
        case noUIDList
        case noNearPath
    }
}

extension FireStoreManager {
    /// 닉네임 중복 확인
    func nickNamePass(nickName: String) async -> (Bool?, Error?) {
        let docRef = db.collection(userInfoPath)
            .whereField(Data.nickName.key, isEqualTo: nickName)
        do {
            if try (await docRef.getDocuments().documents.first?.data()) != nil {
                return (false, nil)
            }
            return (true, nil)
        } catch {
            return (nil, error)
        }
    }
}

extension FireStoreManager {
    func setUserInfo(data: UserInfo) async -> Error? {
        let docRef = db.collection(userInfoPath).document(data.uid)
        do {
            try await docRef.setData(
                encodingValue(data: data)
            )
            return nil
        } catch {
            return error
        }
    }
    
    func setReport(targetUID: String?, title: String, descriptions: String) async -> Error? {
        let docRef = db.collection(reportPath).document(Date().debugDescription)
        do {
            try await docRef.setData([
                "currentUser": FirebaseManager().getUID ?? "익명",
                "targetUser": targetUID ?? "익명",
                "title" : title,
                "descriptions": descriptions
            ])
            return nil
        } catch {
            return error
        }
    }
    
    func setAsk(title: String, descriptions: String) async -> Error? {
        let docRef = db.collection(askPath).document(Date().debugDescription)
        do {
            try await docRef.setData([
                "currentUser": FirebaseManager().getUID ?? "익명",
                "title" : title,
                "descriptions": descriptions
            ])
            return nil
        } catch {
            return error
        }
    }
    
    func setFcmToken(fcmToken: String) async -> Error? {
        let docRef = db.collection(fcmTokenPath).document(FirebaseManager().getUID ?? "")
        do {
            try await docRef.setData([
                "fcmToken": UserDefaultsManager().getValue(forKey: Userdefault_Key.PUSH_KEY) ?? ""
            ])
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
        NotificationManager.shared.postPickCount(count: userList.count)
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
    
    /// 찜 받은 개수 순서대로 출력
    func fetchRanking() async -> (result: [UserInfo]?, error: Error?) {
        let (result, error) = await fetchPickerCount()
        if let error = error {
            return (nil, error)
        }
        var keysArray: [String] = []
        var valuesArray: [Int] = []
        
        if let result = result {
            let sortedRank = result.sorted {
                $0.values.first ?? 0 > $1.values.first ?? 0
            }
            for dictionary in sortedRank {
                for (key, value) in dictionary {
                    keysArray.append(key)
                    valuesArray.append(value)
                }
            }
        }
        var userInfo = await groupTaskForFetchUsers(uidList: keysArray)
        for (index, var element) in userInfo.enumerated() {
            element.heart = valuesArray[index]
            userInfo[index] = element
        }
        return (userInfo, nil)
    }
    
    /// 내가 받은 찜 개수
    func fetchMyPickedCount() async -> (Int?, Error?) {
        guard let uid = FirebaseManager().getUID else { return (nil, FireStoreError.missingUID) }
        let documentRef = db.collection(pickerPath).document(uid)
        
        do {
            let snapshot = try await documentRef.getDocument()
            let data = snapshot.data()?["pick"] as? [Any]
            return (data?.count, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// 내가 차단한 유저
    func fetchShutOutUser() async -> (result: [String]?, error: Error?) {
        guard let uid = FirebaseManager().getUID else { return (nil, FireStoreError.missingUID) }
        let documentRef = db.collection(shutoutPath).document(uid)
        
        do {
            let snapshot = try await documentRef.getDocument()
            let data = snapshot.data()?["shutout"] as? [String]
            if data == nil {
                // 에러는 아니지만 데이터가 없는 경우 아무것도 없는 빈 배열 반환
                return ([], nil)
            }
            return (data, nil)
        } catch {
            CommonUtil.print(output: error.localizedDescription)
            return ([], nil)
        }
    }
    
    /// fcm token
    func fetchFcmToken(uid: String) async -> (result: String?, error: Error?) {
        let docRef = db.collection(fcmTokenPath).document(uid)
        do {
            let document = try await docRef.getDocument()
            let fcmTok = document.data()?["fcmToken"] as? String
            return (fcmTok, nil)
        } catch {
            return (nil, error)
        }
    }
}

extension FireStoreManager {
    func updatePickUser(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
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
    
    func updatePicker(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(pickerPath).document(uuid)
        do {
            try await docRef.updateData([
                Data.pick.key: FieldValue.arrayUnion([uid])
            ])
            return nil
        } catch {
            if (error as NSError).code == 5 {
                do {
                    try await docRef.setData([
                        Data.pick.key: [uid]
                    ])
                    return nil
                } catch {
                    return error
                }
            }
            return error
        }
    }
    
    /// 사용자 차단 메서드
    func updateShutOut(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(shutoutPath).document(uid)
        do {
            try await docRef.updateData([
                Data.shutout.key: FieldValue.arrayUnion([uuid])
            ])
            return nil
        } catch {
            if (error as NSError).code == 5 {
                do {
                    try await docRef.setData([
                        Data.shutout.key: [uuid]
                    ])
                    return nil
                } catch {
                    return error
                }
            }
            return error
        }
    }
    
    func updateBlockUser(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.updateData([
                Data.block.key: FieldValue.arrayUnion([uuid])
            ])
            return nil
        } catch {
            return error
        }
    }
    
    func updateFcmToken(fcmToken: String) async -> Error? {
        let docRef = db.collection(fcmTokenPath).document(FirebaseManager().getUID ?? "")
        do {
            try await docRef.updateData(["fcmToken": UserDefaultsManager().getValue(forKey: Userdefault_Key.PUSH_KEY) ?? ""])
            return nil
        } catch {
            return error
        }
    }
}

extension FireStoreManager {
    func deleteUserInfo() async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.deleteFail }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.delete()
            return nil
        } catch {
            return error
        }
    }
    
    func deletePickUser(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
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
    
    func deletePicker(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(pickerPath).document(uuid)
        do {
            try await docRef.updateData([
                Data.pick.key: FieldValue.arrayRemove([uid])
            ])
            return nil
        } catch {
            return error
        }
    }
    
    func deleteBlockUser(uuid: String) async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            try await docRef.updateData([
                Data.block.key: FieldValue.arrayRemove([uuid])
            ])
            return nil
        } catch {
            return error
        }
    }
    
    func deleteFcmToken() async -> Error? {
        guard let uid = FirebaseManager().getUID else { return FireStoreError.missingUID }
        let docRef = db.collection(fcmTokenPath).document(uid)
        do {
            try await docRef.delete()
            return nil
        } catch {
            return error
        }
    }
}

private extension FireStoreManager {
    func fetchMyPickUsersUID() async -> (result: [String]?, error: Error?) {
        guard let uid = FirebaseManager().getUID else { return (nil, FireStoreError.missingUID) }
        let docRef = db.collection(userInfoPath).document(uid)
        do {
            let document = try await docRef.getDocument()
            let pickUsers = document.data()?[Data.pick.key] as? [String]
            return (pickUsers, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// (uid, 찜 받은 개수)
    func fetchPickerCount() async -> ([[String: Int]]?, Error?) {
        let pickerCollection = db.collection(pickerPath)
        let field = "pick"
        
        do {
            let querySnapshot = try await pickerCollection.order(by: field).getDocuments()
            let result: [[String : Int]] = querySnapshot.documents.map { snapshot in
                let data = snapshot.data()
                let uid = snapshot.documentID
                let pick = data[field] as? [Any] ?? []
                let info = [uid: pick.count]
                return info
            }
            return (result, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func groupTaskForFetchUsers(uidList: [String]) async -> [UserInfo] {
        let datas = await withTaskGroup(of: (Int, UserInfo?).self) { group in
            for (index, uid) in uidList.enumerated() {
                group.addTask {
                    let data = await self.fetchUserInfo(uuid: uid)
                    if let error = data.error {
                        CommonUtil.print(output: "error: \(error.localizedDescription)")
                        return (index, nil)
                    }
                    return (index, data.result)
                }
            }
            var dataList: [UserInfo?] = Array(repeating: nil, count: uidList.count)
            for await (index, userInfo) in group {
                dataList[index] = userInfo
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
        case mbti
        case register
        case introduction
        case pick
        case block
        case heart
        case shutout
        
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
            Data.register.key: data.register,
            Data.mbti.key: data.mbti,
            Data.introduction.key: data.introduction,
            Data.pick.key: data.pick ?? [],
            Data.block.key: data.block ?? []
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
            mbti: data[Data.mbti.key] as? String ?? "",
            introduction: data[Data.introduction.key] as? String ?? "",
            register: data[Data.register.key] as? Date ?? Date(),
            pick: data[Data.pick.key] as? [String] ?? [],
            block: data[Data.block.key] as? [String] ?? [],
            heart: data[Data.heart.key] as? Int ?? 0
        )
    }
}
