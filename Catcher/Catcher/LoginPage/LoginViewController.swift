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
                UserDefaults.standard.set(email, forKey: "email")
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
}
