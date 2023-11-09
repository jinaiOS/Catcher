//
//  NotificationManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() { }
    
    enum NotiName: String {
        case pick
        case report
        var key: String { rawValue }
    }
}

extension NotificationManager {
    func postPickCount(count: Int) {
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.pick.key), object: count, userInfo: nil)
    }
    
    func reportUser() {
        NotificationCenter.default.post(name: NSNotification.Name(NotiName.report.key), object: nil, userInfo: nil)
    }
}
