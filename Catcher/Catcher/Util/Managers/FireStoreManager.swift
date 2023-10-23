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
}

final class FireStoreManager {
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()
    private let userInfoPath = "userInfo"
    private let randomPath = "random"
    private let uid: String?
    
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
    func fetchRandomUser() async -> ([UserInfo]?, Error?) {
        let docRef = db.collection(userInfoPath)
        do {
            let document = try await docRef.getDocuments()
            let userInfo = document.documents.map { $0.data()}
                .randomElements(count: 2)
                .map {
                    decodingValue(data: $0)
                }
            return (userInfo, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchMyPickUser() async -> ([String]?, Error?) {
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
    
    func fetchUserInfo(uuid: String) async -> (UserInfo?, Error?) {
        let docRef = db.collection(userInfoPath).document(uuid)
        do {
            let document = try await docRef.getDocument()
            let userInfo = decodingValue(data: document.data())
            return (userInfo, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchRanking() async -> ([UserInfo]?, Error?) {
        let docRef = db.collection(userInfoPath)
            .order(by: Data.score.key, descending: true)
            .limit(to: 15)
        do {
            let document = try await docRef.getDocuments()
            let userInfoList = document.documents.map {
                $0.data()
            }.map {
                decodingValue(data: $0)
            }
            return (userInfoList, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func fetchNewestUser(date: Date) async -> ([UserInfo]?, Error?) {
        do {
            let querySnapshot = try await db.collection(userInfoPath)
                .whereField(Data.register.key, isGreaterThanOrEqualTo: date)
                .getDocuments()
            let userInfoList = querySnapshot.documents.map { snapshot in
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
    enum Data: String {
        case uid
        case sex
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
    
    func decodingValue(data: [String: Any]?) -> UserInfo {
        UserInfo(
            uid: data?[Data.uid.key] as? String ?? "",
            sex: data?[Data.sex.key] as? String ?? "남성",
            nickName: data?[Data.nickName.key] as? String ?? "",
            location: data?[Data.location.key] as? String ?? "",
            height: data?[Data.height.key] as? Int ?? -1,
            body: data?[Data.body.key] as? String ?? "",
            education: data?[Data.education.key] as? String ?? "",
            drinking: data?[Data.drinking.key] as? String ?? "",
            smoking: data?[Data.smoking.key] as? Bool ?? false,
            register: data?[Data.register.key] as? Date ?? Date(),
            score: data?[Data.score.key] as? Int ?? 0,
            pick: data?[Data.pick.key] as? [String] ?? []
        )
    }
}
