//
//  RegisterView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/19/23.
//

import SnapKit
import UIKit

final class RegisterView: UIView {

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

    var nicknametextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .emailAddress
        return textfield
    }()

    var emailtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .emailAddress
        return textfield
    }()

    var passwordtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .asciiCapable
        return textfield
    }()

    var passwordconfirmtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .asciiCapable
        return textfield
    }()

    private lazy var vstack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillProportionally
        [nicknametextfield, emailtextfield, passwordtextfield, passwordconfirmtextfield].forEach { view.addArrangedSubview($0) }
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
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
            make.bottom.equalTo(self.safeAreaInsets).inset(50)
            make.height.equalTo(50)
        }
    }
}
