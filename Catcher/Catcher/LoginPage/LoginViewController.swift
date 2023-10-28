//
//  LoginViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import FirebaseAuth
import UIKit
final class LoginViewController: UIViewController {
    private let loginView = LoginView()
    override func loadView() {
        super.loadView()
        
        view = loginView
    }
    
    @objc func loginPressed() {
        let email: String = loginView.emailTextField.text!.description
        let pw: String = loginView.passwordTextField.text!.description
        
        // Firebase Auth Login
        Auth.auth().signIn(withEmail: email, password: pw) { authResult, error in
            if authResult != nil {
                print("로그인 성공")
                Task {
                    await self.storeUserInfo()
                }
                AppDelegate.applicationDelegate().changeInitViewController(type: .Main)
            } else {
                print("로그인 실패")
                print(error.debugDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.loginBtn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
    }
    
    func storeUserInfo() async {
        do {
            guard let uid = FireStoreManager.shared.uid else {
                print("Error: UID is nil")
                return
            }
            
            let (userInfo, error) = await FireStoreManager.shared.fetchUserInfo(uuid: uid)
            
            if let userInfo = userInfo {
                // 성공적으로 정보를 가져온 경우
                print(userInfo)
                DataManager.sharedInstance.userInfo = userInfo
            } else if let error = error {
                // 오류가 발생한 경우
                print("Error: \(error)")
            }
        }
    }
}
