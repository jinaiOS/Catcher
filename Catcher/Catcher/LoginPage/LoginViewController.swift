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
        self.processIndicatorView(isHide: false)

        let email: String = loginView.emailTextField.tf.text!.description
        let pw: String = loginView.passwordTextField.tf.text!.description
        
        FirebaseManager().emailLogIn(email: email, password: pw) { error in
            if let error = error {
                CommonUtil.print(output: "로그인 실패: \(error)")
                self.loginView.emailTextField.isError = true
                self.loginView.passwordTextField.isError = true
                self.processIndicatorView(isHide: true)
            } else {
                CommonUtil.print(output: "로그인 성공")
                Task {
                    if let uid = FirebaseManager().getUID {
                        let (result, _) = await FireStoreManager.shared.fetchUserInfo(uuid: uid)
                        if let result {
                            UserDefaultsManager().setValue(value: result.location, key: "location")
                        }
                    }    
                }
                
                Task {
                    await self.storeUserInfo()
                    let (result, error) = await FireStoreManager.shared.fetchFcmToken(uid: FirebaseManager().getUID ?? "")
                    if let error {
                        CommonUtil.print(output: error.localizedDescription)
                        return
                    }
                    if result == nil {
                        let error = await FireStoreManager.shared.setFcmToken(fcmToken: UserDefaultsManager().getValue(forKey: Userdefault_Key.PUSH_KEY) ?? "")
                        if let error {
                            CommonUtil.print(output: error)
                        }
                    } else {
                        let error = await FireStoreManager.shared.updateFcmToken(fcmToken: UserDefaultsManager().getValue(forKey: Userdefault_Key.PUSH_KEY) ?? "")
                        if let error {
                            CommonUtil.print(output: error)
                        }
                    }
                }
                self.processIndicatorView(isHide: true)
                AppDelegate.applicationDelegate().changeInitViewController(type: .Main)
            }
        }
    }
    
    @objc func signUpPressed() {
        let vc = RegisterViewController()
        navigationPushController(viewController: vc, animated: true)
    }
    
    @objc func resetPasswordButton() {
        let vc = ResetPWViewController()
        navigationPushController(viewController: vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.loginBtn.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginView.signUpBtn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        loginView.resetPasswordBtn.addTarget(self, action: #selector(resetPasswordButton), for: .touchUpInside)
        
        loginView.indicator.hidesWhenStopped = true
        loginView.indicator.stopAnimating()
        loginView.indicator.style = .large
        loginView.indicator.color = .systemOrange
        loginView.indicatorView.isHidden = true
        
        setUI()
    }
    
    func processIndicatorView(isHide: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            loginView.indicatorView.isHidden = isHide
            if isHide {
                loginView.indicator.stopAnimating()
            } else {
                loginView.indicator.startAnimating()
            }
        }
    }
    
    func storeUserInfo() async {
        let nearUserPath = "location"
        do {
            guard let uid = FirebaseManager().getUID else {
                CommonUtil.print(output: "Error: UID is nil")
                return
            }
            
            let (userInfo, error) = await FireStoreManager.shared.fetchUserInfo(uuid: uid)
            
            if let userInfo = userInfo {
                // 성공적으로 정보를 가져온 경우
                CommonUtil.print(output: userInfo)
                UserDefaultsManager().setValue(value: userInfo.location, key: nearUserPath)
            } else if let error = error {
                // 오류가 발생한 경우
                CommonUtil.print(output: "Error: \(error)")
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
    
    func customTextFieldDidEndEditing(_ textField: UITextField) {}
    
    func customTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == loginView.emailTextField.tf {
            loginView.emailTextField.isError = false // next 버튼 선택 시 -> tfPW 포커싱
        } else {
            loginView.passwordTextField.isError = false // return 버튼 선택 시 -> 키보드 내려감
        }
    }
    
    func errorStatus(isError: Bool, view: CustomTextField) {}
    
    func customTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 30 // 30개 제한
    }
}
