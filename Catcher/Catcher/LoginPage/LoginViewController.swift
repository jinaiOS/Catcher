//
//  LoginViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import UIKit

final class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    
    override func loadView() {
        super.loadView()
        
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}





