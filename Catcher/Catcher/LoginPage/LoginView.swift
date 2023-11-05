//
//  LoginView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import SnapKit
import UIKit

final class LoginView: UIView {
    lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.tf.keyboardType = .emailAddress
//        textField.textColor = .label
//        textField.font = .systemFont(ofSize: 15, weight: .regular)
//        textField.keyboardType = .emailAddress
//        textField.autocapitalizationType = .none
        return textField
    }()
    
    lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.tf.keyboardType = .asciiCapable
        return textField
    }()
    
    lazy var loginBtn: UIButton = ButtonFactory.makeButton(
        title: "로그인",
        titleLabelFont: .systemFont(ofSize: 25, weight: .bold),
        titleColor: .white,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 15)
    
    lazy var findIDBtn: UIButton = ButtonFactory.makeButton(
        title: "아이디 찾기",
        titleColor: .darkGray,
        cornerRadius: 15)
    
    lazy var resetPasswordBtn: UIButton = ButtonFactory.makeButton(
        title: "비밀번호 재설정",
        titleColor: .darkGray,
        cornerRadius: 15)
    
    lazy var signUpBtn: UIButton = ButtonFactory.makeButton(
        title: "회원가입",
        titleColor: .darkGray,
        cornerRadius: 15)

//    lazy var appleLoginBtn: UIButton = ButtonFactory.makeButton(
//        type: .custom,
//        image: UIImage(named: "appleid_button"),
//        cornerRadius: 15)
    
    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fillEqually
        
        [emailTextField, passwordTextField].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        
        [resetPasswordBtn, signUpBtn].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = ThemeColor.backGroundColor
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoginView {
    func makeLabel(text: String) -> UILabel {
        LabelFactory.makeLabel(
            text: text,
            font: ThemeFont.regular(size: 20),
            textAlignment: .left)
    }
    
    func setLayout() {
        [vStack, loginBtn, hStack].forEach {
            addSubview($0)
        }
        
        vStack.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(100)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.height.equalTo(200)
        }
        
        loginBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.top.equalTo(vStack.snp.bottom).offset(30)
        }
//        appleLoginBtn.snp.makeConstraints { make in
//            make.top.equalTo(loginBtn.snp.bottom).offset(50)
//            make.width.equalTo(200)
//            make.centerX.equalToSuperview()
//        }
        hStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-30)
        }
//        eyeButton.snp.makeConstraints { make in
//            make.centerX.centerY.equalTo(self.passwordTextField)
//            make.trailing.equalTo(-20)
//            make.width.height.equalTo(40)
//        }
    }
}
