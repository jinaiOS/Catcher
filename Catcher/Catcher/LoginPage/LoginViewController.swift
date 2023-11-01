//
//  LoginViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import FirebaseAuth
import UIKit

class LoginViewController: BaseViewController {
    private let loginView = LoginView()
    override func loadView() {
        super.loadView()
        
        view = loginView
    }
    
    @objc func loginPressed() {
        let email: String = loginView.emailTextField.tf.text!.description
        let pw: String = loginView.passwordTextField.tf.text!.description
        
        FirebaseManager().emailLogIn(email: email, password: pw) { error in
            if let error = error {
                CommonUtil.print(output: "로그인 실패: \(error)")
                self.loginView.emailTextField.isError = true
                self.loginView.passwordTextField.isError = true
            } else {
                CommonUtil.print(output:"로그인 성공")
                Task {
                    await self.storeUserInfo()
                }
                AppDelegate.applicationDelegate().changeInitViewController(type: .Main)
            }
        }
    }
  
    @objc func signUpPressed() {
        let vc = RegisterViewController()
        self.navigationPushController(viewController: vc, animated: true)
    }
    
    @objc func resetPasswordButton() {
        let vc = ResetPWViewController()
        self.navigationPushController(viewController: vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.loginBtn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginView.signUpBtn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        loginView.resetPasswordBtn.addTarget(self, action: #selector(resetPasswordButton), for: .touchUpInside)
        setUI()
    }
    
    func storeUserInfo() async {
        do {
            guard let uid = FirebaseManager().getUID else {
                CommonUtil.print(output:"Error: UID is nil")
                return
            }
            
            let (userInfo, error) = await FireStoreManager.shared.fetchUserInfo(uuid: uid)
            
            if let userInfo = userInfo {
                // 성공적으로 정보를 가져온 경우
                CommonUtil.print(output: userInfo)
                DataManager.sharedInstance.userInfo = userInfo
            } else if let error = error {
                // 오류가 발생한 경우
                CommonUtil.print(output:"Error: \(error)")
            }
        }
    }
    
    // 이메일 아이디, 패스워드 - placeholder, keyboardtype, delegate 설정
    func setUI() {
        loginView.emailTextField.initTextFieldText(placeHolder: "이메일을 입력해 주세요", delegate: self)
        loginView.emailTextField.lblTitle.text = "이메일"
        loginView.emailTextField.lblError.text = "올바른 이메일 형식을 입력해 주세요"
        loginView.emailTextField.tf.keyboardType = .emailAddress
        loginView.emailTextField.tf.returnKeyType = .next
        
        loginView.passwordTextField.initTextFieldText(placeHolder: "비밀번호를 입력해 주세요", delegate: self)
        loginView.passwordTextField.lblTitle.text = "비밀번호"
        loginView.passwordTextField.lblError.text = "올바른 비밀번호 형식을 입력해 주세요"
        loginView.passwordTextField.tf.returnKeyType = .done
        loginView.passwordTextField.textFieldIsPW(isPW: true)
    }
}

extension LoginViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.emailTextField.tf {
            loginView.passwordTextField.tf.becomeFirstResponder() // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            loginView.passwordTextField.tf.resignFirstResponder() // return 버튼 선택 시 -> 키보드 내려감
        }
        return true
    }
    
    func customTextFieldValueChanged(_ textfield: UITextField) {
        if textfield == loginView.emailTextField.tf {
            loginView.emailTextField.isError = false // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            loginView.passwordTextField.isError = false // return 버튼 선택 시 -> 키보드 내려감
        }
    }
    
    func customTextFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func customTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == loginView.emailTextField.tf {
            loginView.emailTextField.isError = false // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            loginView.passwordTextField.isError = false // return 버튼 선택 시 -> 키보드 내려감
        }
    }
    
    func errorStatus(isError: Bool, view: CustomTextField) {
        
    }
    
    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30 // 30개 제한
    }
}
