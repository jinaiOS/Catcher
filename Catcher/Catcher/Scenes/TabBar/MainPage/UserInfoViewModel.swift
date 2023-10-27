//
//  UserInfoViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class UserInfoViewModel {
    private let fireStoreManager = FireStoreManager.shared
    private let userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
}

extension UserInfoViewModel {
    func processPickUser(isUpdate: Bool,
                         completion: @escaping (_ result: [UserInfo]?, _ error: Error?) -> Void) {
        Task {
            var result: [UserInfo]?
            var error: Error?
            
            if isUpdate {
                error = await fireStoreManager.updatePickUser(uuid: userInfo.uid)
            } else {
                error = await fireStoreManager.deletePickUser(uuid: userInfo.uid)
            }
            if let error = error {
                completion(nil, error)
                return
            }
            
            (result, error) = await fireStoreManager.fetchPickUsers()
            if let error = error {
                completion(nil, error)
                return
            }
            completion(result, nil)
        }
    }
    
    func makeInfo(info: UserInfo) -> String {
        let smoking = info.smoking ? "흡연" : "비흡연"
        
        let text = """
        닉네임: \(info.nickName)
        키: \(info.height)
        체형: \(info.body)
        음주: \(info.drinking)
        흡연: \(smoking)
        학력: \(info.education)
        지역: \(info.location)
        점수: \(info.score)
        """
        return text
    }
}
