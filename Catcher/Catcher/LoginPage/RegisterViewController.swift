//
//  RegisterViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/18/23.
//

import FirebaseAuth
import FirebaseFirestore
import SnapKit
import UIKit
final class RegisterViewController: BaseViewController {
    private let registerView = RegisterView()
    private let fireManager = FirebaseManager()
    
    /** @brief 공통 헤더 객체 */
    var headerView : CommonHeaderView!

    @objc func nextPressed() {
        guard let nickName = registerView.nicknametextfield.text, !nickName.isEmpty else {
            showAlert(title: "닉네임을 입력하세요", message: "닉네임을 입력해주세요.")
            return
        }

        guard let email = registerView.emailtextfield.text, isValidEmail(email) else {
            showAlert(title: "유효하지 않은 이메일", message: "올바른 이메일 주소를 입력하세요.")
            return
        }

        guard let password = registerView.passwordtextfield.text, !password.isEmpty, password == registerView.passwordconfirmtextfield.text, password.count >= 6 else {
            showAlert(title: "유효하지 않은 비밀번호", message: "비밀번호를 다시 확인해주세요.")
            return
        }
//        guard let nickName = registerView.nicknametextfield.text else { return }
//        guard let email = registerView.emailtextfield.text else { return }
//        guard let password = registerView.passwordtextfield.text else { return }
        let vcInfo = InfoViewController()
        vcInfo.newUserEmail = email
        vcInfo.newUserPassword = password
        vcInfo.newUserNickName = nickName
        navigationController?.pushViewController(vcInfo, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }


    func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    func setHeaderView() {
        headerView = CommonHeaderView.init(frame: CGRect.init(x: 0, y: Common.kStatusbarHeight, width: Common.SCREEN_WIDTH(), height: 50))
        
        view.addSubview(headerView)
        
        headerView.lblTitle.text = "회원가입"
    }
    
    /**
     @brief backButton을 눌렀을때 들어오는 이벤트
     
     @param sender 버튼 객체
     */
    @objc func backButtonTouched(sender : UIButton)
    {
        navigationPopViewController(animated: true) { () -> (Void) in }
    }

    override func loadView() {
        super.loadView()
        view.addSubview(registerView)
        
        registerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaInsets).offset(80)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        registerView.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //gesture의 이벤트가 끝나도 뒤에 이벤트를 View로 전달
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setHeaderView()
    }
}
