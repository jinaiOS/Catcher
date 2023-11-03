//
//  AppVersionViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class AppVersionViewController: BaseViewController {
    private let appVersionView = AppVersionView()
    
    override func loadView() {
        super.loadView()
        
        view = appVersionView
    }
}
