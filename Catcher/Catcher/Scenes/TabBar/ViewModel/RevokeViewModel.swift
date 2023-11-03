//
//  RevokeViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

final class RevokeViewModel {
    private let firebaseManager = FirebaseManager()
}

extension RevokeViewModel {
    func reAuthenticate(password: String, completion: @escaping (Bool) -> Void) {
        Task {
            if await firebaseManager.reAuthenticate(password: password) {
                DispatchQueue.main.async {
                    completion(true)
                    return
                }
            }
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    /// 주의!!! 모든 정보 삭제하기
    func removeAllInfo(completion: @escaping () -> Void) {
        removeAllUserDefauls()
        FireStorageManager.shared.deleteProfileData { error in
            if let error {
                CommonUtil.print(output: error)
            }
        }
        Task {
            let error = await FireStoreManager.shared.deleteUserInfo()
            let _ = await firebaseManager.removeUser()
            if let error {
                CommonUtil.print(output: error)
            }
        }
        completion()
    }
}

private extension RevokeViewModel {
    /// 주의!!! UserDefaults에 저장된 모든 데이터 삭제
    func removeAllUserDefauls() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
        }
    }
}
