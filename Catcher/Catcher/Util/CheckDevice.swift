//
//  CheckDevice.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class CheckDevice {
    private let fireStoreManager = FireStoreManager.shared
}

extension CheckDevice {
    /// 문제 되는 디바이스인지 확인
    func isProblemDevice(completion: @escaping (Bool) -> Void) {
        let deviceName = getDeviceModelName()
        
        fetchProblemDevice { devices in
            if devices.contains(deviceName) {
                UserDefaultsManager().setValue(value: true, key: UserDefaultsManager.keyName.problem.key)
                completion(true)
                return
            }
            UserDefaultsManager().setValue(value: false, key: UserDefaultsManager.keyName.problem.key)
            completion(false)
        }
    }
}

private extension CheckDevice {
    func fetchProblemDevice(completion: @escaping ([String]) -> Void) {
        Task {
            let (result, error) = await fireStoreManager.fetchDevice()
            if let error {
                CommonUtil.print(output: error.localizedDescription)
                completion([])
                return
            }
            guard let result = result else {
                completion([])
                return
            }
            completion(result)
            return
        }
    }
    
    /// 디바이스 모델명 조회
    func getDeviceModelName() -> String {
        var modelName = ""
        
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)
        
        if device.responds(to: selector) {
            modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
        }
        return modelName
    }
}
