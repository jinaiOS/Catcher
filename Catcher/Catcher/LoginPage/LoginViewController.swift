//
//  LoginViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import FirebaseAuth
import UIKit

/**
 @class LoginViewController.swift
 
 @brief LoginViewController를 상속받은 ViewController
 
 @detail 로그인 기능이 있는  LoginViewController
 */
class LoginViewController: BaseViewController {
    private let loginView = LoginView()
    override func loadView() {
        super.loadView()
        
        view = loginView
    }
    
    /** @brief emailTextField,passwordTextField에서 입력받은 아이디, 비밀번호로 로그인 시도   */
    @objc func loginPressed(sender: UIButton) {
        sender.debounce()
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
                // 디바이스 체크
                CheckDevice().isProblemDevice { problem in
                    CommonUtil.print(output: "캐리커처 지원 제한 기기: \(problem)")
                }
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
    
    /** @brief signUpBtn 터치로 회원가입 페이지 이동   */
    @objc func signUpPressed() {
        let vc = RegisterViewController()
        navigationPushController(viewController: vc, animated: true)
    }
    
    /** @brief resetPasswordBtn 터치로 비밀번호 변경 페이지 이동   */
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
    
    /** @brief Indicator 표시, 숨기는 함수  */
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
    
    /** @brief Firebase에서 사용자 정보를 가져와서 해당 정보를 로컬에 저장하는 비동기 함수  */
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
    
    /**
     @brief CustomTextFieldDelegate의 Delegate
     */
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
            loginView.emailTextField.isError = false // 에러 표시 초기화
        } else {
            loginView.passwordTextField.isError = false // 에러 표시 초기화
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
