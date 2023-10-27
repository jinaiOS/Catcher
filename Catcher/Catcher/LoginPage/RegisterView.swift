//
//  RegisterView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/19/23.
//

import SnapKit
import UIKit

final class RegisterView: UIView {
    private lazy var nicknameLabel: UILabel = LabelFactory.makeLabel(text: "닉네임", font: ThemeFont.regular(size: 22), textAlignment: .left)

    private lazy var emailLabel: UILabel = LabelFactory.makeLabel(text: "이메일", font: ThemeFont.regular(size: 22), textAlignment: .left)

    private lazy var passwordLabel: UILabel = LabelFactory.makeLabel(text: "비밀번호", font: ThemeFont.regular(size: 22), textAlignment: .left)

    private lazy var passwordConfirmLabel: UILabel = LabelFactory.makeLabel(text: "비밀번호 확인", font: ThemeFont.regular(size: 22), textAlignment: .left)

    lazy var provisionButton: UIButton = ButtonFactory.makeButton(
        title: "약관동의",
        titleColor: .darkGray)

    lazy var ageButton: UIButton = ButtonFactory.makeButton(
        title: "14세 이상입니다.",
        titleColor: .darkGray)

    lazy var nextButton: UIButton = ButtonFactory.makeButton(
        title: "다음",
        titleColor: .white,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 15)

    var nicknametextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "닉네임을 입력해주세요"
        textfield.keyboardType = .emailAddress
        textfield.font = ThemeFont.regular(size: 17)
        return textfield
    }()

    var emailtextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "이메일을 입력해주세요"
        textfield.keyboardType = .emailAddress
        textfield.font = ThemeFont.regular(size: 17)
        return textfield
    }()

    var passwordtextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "비밀번호를 입력해주세요"
        textfield.keyboardType = .asciiCapable
        textfield.font = ThemeFont.regular(size: 17)
        return textfield
    }()

    var passwordconfirmtextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "비밀번호 확인을 해주세요"
        textfield.keyboardType = .asciiCapable
        textfield.font = ThemeFont.regular(size: 17)
        return textfield
    }()

    private lazy var vstack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.addArrangedSubview(nicknameLabel)
        view.addArrangedSubview(nicknametextfield)
        view.addArrangedSubview(separateView)
        view.addArrangedSubview(emailLabel)
        view.addArrangedSubview(emailtextfield)
        view.addArrangedSubview(separateView)
        view.addArrangedSubview(passwordLabel)
        view.addArrangedSubview(passwordtextfield)
        view.addArrangedSubview(separateView)
        view.addArrangedSubview(passwordConfirmLabel)
        view.addArrangedSubview(passwordconfirmtextfield)
        view.addArrangedSubview(separateView)
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        setlayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RegisterView {
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary

        view.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return view
    }

    func setlayout() {
        addSubview(vstack)
        addSubview(provisionButton)
        addSubview(ageButton)
        addSubview(nextButton)
        vstack.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(50)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(AppConstraint.defaultSpacing)
        }
        provisionButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.top.equalTo(vstack.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        ageButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.top.equalTo(provisionButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-100)
            make.height.equalTo(50)
        }
    }
}
