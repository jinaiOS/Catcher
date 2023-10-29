//
//  LoginView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import SnapKit
import UIKit

final class LoginView: UIView {
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해 주세요."
        textField.borderStyle = .none
        textField.textColor = .label
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해 주세요."
        textField.borderStyle = .none
        textField.textColor = .label
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
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

    lazy var appleLoginBtn: UIButton = ButtonFactory.makeButton(
        type: .custom,
        image: UIImage(named: "appleid_button"),
        cornerRadius: 15)
    
    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .equalSpacing
        
        [makeLabel(text: "아이디"), emailTextField, separateView,
         makeLabel(text: "비밀번호"), passwordTextField, separateView].forEach {
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
        backgroundColor = .white
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var eyeButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn = UIButton(primaryAction: UIAction(handler: { [self] _ in
            passwordTextField.isSecureTextEntry.toggle()
            self.eyeButton.isSelected.toggle()
        }))
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.imagePadding = 10
        buttonConfiguration.baseBackgroundColor = .clear
        btn.tintColor = ThemeColor.primary
        
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.setImage(UIImage(systemName: "eye"), for: .selected)
        btn.configuration = buttonConfiguration
        
        return btn
    }()
}

private extension LoginView {
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        
        view.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return view
    }

    func makeLabel(text: String) -> UILabel {
        LabelFactory.makeLabel(
            text: text,
            font: ThemeFont.regular(size: 20),
            textAlignment: .left)
    }
    
    func setLayout() {
        [vStack, loginBtn, appleLoginBtn, eyeButton, hStack].forEach {
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
        appleLoginBtn.snp.makeConstraints { make in
            make.top.equalTo(loginBtn.snp.bottom).offset(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        hStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-30)
        }
        eyeButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self.passwordTextField)
            make.trailing.equalTo(-20)
            make.width.height.equalTo(40)
        }
    }
}
