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
final class RegisterViewController: BaseHeaderViewController {
    private let registerView = RegisterView()
    private let fireManager = FirebaseManager()

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
        let vcInfo = InfoViewController(title: "기본 프로필")
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

    override func loadView() {
        super.loadView()
        view = registerView
    }

    override func viewDidLoad() {
        registerView.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
    }
}
