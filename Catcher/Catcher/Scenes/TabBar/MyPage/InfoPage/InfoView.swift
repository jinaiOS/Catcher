//
//  InfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class InfoView: UIView {
    private let isValidNickName: Bool

    lazy var nickNameTextField: CustomTextField = {
        let textField = CustomTextField()
        return textField
    }()

    lazy var regionTextField: CustomTextField = {
        let textField = CustomTextField()
        return textField
    }()

    lazy var mbtiTextField: CustomTextField = {
        let textField = CustomTextField()
        return textField
    }()

    lazy var heightTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.tf.keyboardType = .numberPad
        return textField
    }()

    lazy var birthTextField: CustomTextField = {
        let textField = CustomTextField()
        return textField
    }()

    lazy var introduceTextField: CustomTextField = {
        let textField = CustomTextField()
        return textField
    }()
    
    lazy var warningLabel: UILabel = {
       let label = UILabel()
        label.text = "부적절하거나 불쾌감을 줄 수 있는 컨텐츠는 제재를 받을 수 있습니다."
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.font = ThemeFont.regular(size: 13)
        return label
    }()

    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = AppConstraint.stackViewSpacing

        if isValidNickName {
            view.addArrangedSubview(nickNameTextField)
        }
        [regionTextField,
         birthTextField,
         mbtiTextField,
         heightTextField,
         introduceTextField].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()

    lazy var contentView: UIView = {
        let vw = UIView()
        vw.addSubview(vStack)
        vw.addSubview(warningLabel)
        vw.addSubview(saveButton)
        return vw
    }()

    lazy var scrollView: UIScrollView = {
        let vw = UIScrollView()
        vw.addSubview(contentView)
        return vw
    }()

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = ThemeFont.demibold(size: 25)
        button.backgroundColor = ThemeColor.primary
        button.layer.cornerRadius = 15
        return button
    }()

    init(isValidNickName: Bool = false) {
        self.isValidNickName = isValidNickName
        super.init(frame: .zero)
        backgroundColor = ThemeColor.backGroundColor
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InfoView {
    func getLabelSize(text: String, font: UIFont) -> (CGFloat, CGFloat) {
        let label = UILabel()
        label.text = text
        label.font = font
        label.sizeToFit()
        return (label.bounds.width, label.bounds.height)
    }

    func setLayout() {
        [scrollView].forEach {
            addSubview($0)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(AppConstraint.headerViewHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.centerX.equalToSuperview()
        }
        vStack.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        warningLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.top.equalTo(vStack.snp.bottom).inset(-10)
//            $0.height.equalTo(18)
        }
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.top.equalTo(warningLabel.snp.bottom).inset(-50)
            $0.height.equalTo(50)
            $0.bottom.equalTo(contentView).inset(20)
        }
    }
}
