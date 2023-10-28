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
    
    func calculateAge(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        let age = ageComponents.year ?? 0
        
        return age
    }
}
