//
//  UserInfoViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class UserInfoViewModel {
    private let fireStoreManager = FireStoreManager.shared
    let userInfo: UserInfo
    let isPicked: Bool
    let isBlocked: Bool
    
    init(userInfo: UserInfo, isPicked: Bool, isBlocked: Bool) {
        self.userInfo = userInfo
        self.isPicked = isPicked
        self.isBlocked = isBlocked
    }
}

extension UserInfoViewModel {
    var isMe: Bool {
        guard let uid = FirebaseManager().getUID else { return false }
        if userInfo.uid == uid { return true }
        return false
    }
    
    func processPickUser(isUpdate: Bool,
                         completion: @escaping (_ result: [UserInfo]?, _ error: Error?) -> Void) {
        Task {
            var result: [UserInfo]?
            var error: Error?
            
            if isUpdate {
                error = await fireStoreManager.updatePickUser(uuid: userInfo.uid)
                error = await fireStoreManager.updatePicker(uuid: userInfo.uid)
            } else {
                error = await fireStoreManager.deletePickUser(uuid: userInfo.uid)
                error = await fireStoreManager.deletePicker(uuid: userInfo.uid)
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
    
    func processBlockUser(isBlock: Bool, completion: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        Task {
            var error: Error?
            
            if isBlock {
                error = await fireStoreManager.updateBlockUser(uuid: userInfo.uid)
            } else {
                error = await fireStoreManager.deleteBlockUser(uuid: userInfo.uid)
            }
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func isBlockedUser(searchTarget: String, containUID: String, completion: @escaping (_ result: Bool) -> Void) {
        Task {
            let (result, error) = await fireStoreManager.fetchUserInfo(uuid: searchTarget)
            if let error {
                CommonUtil.print(output: error.localizedDescription)
                return
            }
            guard let result = result,
                    let block = result.block else { return }
            let isBlocked = block.contains(containUID)
            completion(isBlocked)
        }
    }
}
