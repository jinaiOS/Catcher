//
//  UserDefaultsManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

final class UserDefaultsManager {
    enum keyName: String {
        case problem
        
        var key: String { rawValue }
    }
}

extension UserDefaultsManager {
    func setValue<T>(value: T, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getValue<T>(forKey key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
}
