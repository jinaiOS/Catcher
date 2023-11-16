//
//  LoginView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/17/23.
//

import SnapKit
import UIKit

/**
 @class LoginView.swift
 
 @brief LoginViewController의 기본 View
 */
final class LoginView: UIView {
    
    /** @brief CustomTextField를 상속받은 emailTextField   */
    lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.tf.keyboardType = .emailAddress
        return textField
    }()
    
    /** @brief CustomTextField를 상속받은 passwordTextField   */
    lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.tf.keyboardType = .asciiCapable
        return textField
    }()
    
    /** @brief ButtonFactory를 상속받은 loginBtn   */
    lazy var loginBtn: UIButton = ButtonFactory.makeButton(
        title: "로그인",
        titleLabelFont: ThemeFont.demibold(size: 25),
        titleColor: .white,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 15)
    
    /** @brief ButtonFactory를 상속받은 findIDBtn   */
    lazy var findIDBtn: UIButton = ButtonFactory.makeButton(
        title: "아이디 찾기",
        titleColor: .darkGray,
        cornerRadius: 15)
    
    /** @brief ButtonFactory를 상속받은 resetPasswordBtn   */
    lazy var resetPasswordBtn: UIButton = ButtonFactory.makeButton(
        title: "비밀번호 재설정",
        titleColor: .darkGray,
        cornerRadius: 15)
    
    /** @brief ButtonFactory를 상속받은 loginBtn   */
    lazy var signUpBtn: UIButton = ButtonFactory.makeButton(
        title: "회원가입",
        titleColor: .darkGray,
        cornerRadius: 15)
    
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
    
    let indicator = UIActivityIndicatorView()
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
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
    /**
     @brief LoginView의 Constaints 설정
     */
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
        hStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-30)
        }
        
        indicatorView.addSubview(indicator)
        
        self.addSubview(indicatorView)
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
