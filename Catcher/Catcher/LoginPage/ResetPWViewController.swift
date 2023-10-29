//
//  ResetPWViewController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/30.
//

import UIKit

class ResetPWViewController: BaseHeaderViewController {

    private lazy var emailLabel: UILabel = LabelFactory.makeLabel(text: "아이디", font: ThemeFont.regular(size: 22), textAlignment: .left)
    
    lazy var emailTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "아이디를 입력해주세요"
        textfield.keyboardType = .emailAddress
        textfield.font = ThemeFont.regular(size: 17)
        textfield.autocapitalizationType = .none
        return textfield
    }()
    
    lazy var separateView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        return view
    }()
    
    lazy var loginBtn: UIButton = ButtonFactory.makeButton(
        title: "메일 전송하기",
        titleColor: .white,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderTitleName(title: "비밀번호 재설정")
        setLayout()
        view.backgroundColor = .white
        loginBtn.addTarget(self, action: #selector(requestResetPW), for: .touchUpInside)
    }
    
    func setLayout() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextfield)
        view.addSubview(separateView)
        view.addSubview(loginBtn)
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaInsets).offset(150)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        emailTextfield.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        separateView.snp.makeConstraints {
            $0.top.equalTo(emailTextfield.snp.bottom).offset(5)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        loginBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.bottom.equalTo(view.safeAreaInsets).inset(50)
        }
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
    
    func showAlertAction(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            self.navigationPopViewController(animated: true) {
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func requestResetPW() {
        if emailTextfield.text ?? "" == "" {
            showAlert(title: "아이디를 작성해 주세요.", message: "")
        } else {
            Task {
                let isSuccess = await FirebaseManager().sendEmailForChangePW(email: emailTextfield.text ?? "")
                if isSuccess {
                    showAlertAction(title: "이메일 전송 성공했습니다.", message: "메일을 확인해 주세요")
                } else {
                    showAlert(title: "이메일 전송 실패했습니다.", message: "")
                }
            }
        }
    }
}
