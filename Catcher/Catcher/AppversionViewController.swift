//
//  AppversionViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/27/23.
//

import UIKit

final class AppversionViewController: UIViewController{
    private let appversionview = AppversionView()
    override func loadView() {
        super.loadView()
        view = appversionview
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
