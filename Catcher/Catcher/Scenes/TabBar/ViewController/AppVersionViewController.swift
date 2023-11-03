//
//  AppVersionViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class AppVersionViewController: BaseHeaderViewController {
    private let appVersionView = AppVersionView()
    
    override func loadView() {
        super.loadView()
        
        view = appVersionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    deinit {
        CommonUtil.print(output: "deinit - AppVersionVC")
    }
}

private extension AppVersionViewController {
    func configure() {
        setHeaderTitleName(title: "앱 버전")
    }
}
