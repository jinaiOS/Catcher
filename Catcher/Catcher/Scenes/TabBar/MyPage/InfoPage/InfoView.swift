//
//  InfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class InfoView: UIView {
    var selectedBodyButton: UIButton?
    var selectedDrinkButton: UIButton?
    var selectedSmokeButton: UIButton?
    lazy var regionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "지역을 입력해 주세요"
        return textField
    }()
    
    lazy var educationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "학력을 입력해 주세요"
        return textField
    }()
    
    lazy var heightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "키를 입력해 주세요"
        return textField
    }()
    
    lazy var thinBodyBtn: UIButton = bodyButton(title: "마름")
    
    lazy var nomalBodyBtn: UIButton = bodyButton(title: "평범함")
    
    lazy var chubbyBodyBtn: UIButton = bodyButton(title: "통통함")
    
    lazy var fatBodyBtn: UIButton = bodyButton(title: "뚱뚱함")
    
    lazy var drinkingNoBtn: UIButton = drinkButton(title: "안 마심")
    
    lazy var drinkingTwiceBtn: UIButton = drinkButton(title: "주 1~2회")
    
    lazy var drinkingOftenBtn: UIButton = drinkButton(title: "주 3~5")
    
    lazy var drinkingDailyBtn: UIButton = drinkButton(title: "그 이상")
    
    lazy var smokingBtn: UIButton = smokeButton(title: "흡연")
    
    lazy var noSmokingBtn: UIButton = smokeButton(title: "비흡연")
    
    @objc func bodyButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let selectedBodyButton = selectedBodyButton {
            selectedBodyButton.isSelected = false
            selectedBodyButton.backgroundColor = .systemGray4
            selectedBodyButton.setTitleColor(.darkGray, for: .normal)
        }
        sender.isSelected = true
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = ThemeColor.primary

        selectedBodyButton = sender // 선택된 버튼 업데이트
    }

    @objc func drinkButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let selectedDrinkButton = selectedDrinkButton {
            selectedDrinkButton.isSelected = false
            selectedDrinkButton.backgroundColor = .systemGray4
            selectedDrinkButton.setTitleColor(.darkGray, for: .normal)
        }
        sender.isSelected = true
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = ThemeColor.primary

        selectedDrinkButton = sender // 선택된 버튼 업데이트
    }
    
    @objc func smokeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let selectedSmokeButton = selectedSmokeButton {
            selectedSmokeButton.isSelected = false
            selectedSmokeButton.backgroundColor = .systemGray4
            selectedSmokeButton.setTitleColor(.darkGray, for: .normal)
        }
        sender.isSelected = true
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = ThemeColor.primary

        selectedSmokeButton = sender // 선택된 버튼 업데이트
    }
    
    private lazy var bodyHstack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = AppConstraint.stackViewSpacing
        
        [thinBodyBtn, nomalBodyBtn, chubbyBodyBtn, fatBodyBtn].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var drinkingHstack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = AppConstraint.stackViewSpacing
        
        [drinkingNoBtn, drinkingTwiceBtn, drinkingOftenBtn, drinkingDailyBtn].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var smokingHstack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = AppConstraint.stackViewSpacing
        
        [smokingBtn, noSmokingBtn].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = AppConstraint.stackViewSpacing
        
        [makeLabel(text: "지역"), regionTextField, separateView,
         makeLabel(text: "학력"), educationTextField, separateView,
         makeLabel(text: "키"), heightTextField, separateView,
         makeLabel(text: "체형"), bodyHstack, separateView,
         makeLabel(text: "음주"), drinkingHstack, separateView,
         makeLabel(text: "흡연"), smokingHstack].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = ThemeFont.demibold(size: 20)
        button.backgroundColor = ThemeColor.primary
        button.layer.cornerRadius = 15
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InfoView {
    func bodyButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = ThemeFont.regular(size: 15)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(bodyButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    func drinkButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = ThemeFont.regular(size: 15)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(drinkButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    func smokeButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = ThemeFont.regular(size: 15)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(smokeButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    func makeLabel(text: String) -> UILabel {
        return LabelFactory.makeLabel(
            text: text,
            font: ThemeFont.demibold(size: 18),
            textAlignment: .left)
    }
    
    func makeButton(text: String) -> UIButton {
        return ButtonFactory.makeButton(
            title: text,
            titleLabelFont: ThemeFont.regular(size: 15),
            titleColor: .darkGray,
            backgroundColor: .systemGray4,
            cornerRadius: 15)
        
//        let size = getLabelSize(text: text, font: font)
        
//        button.snp.makeConstraints {
//            $0.width.equalTo(size.0 + 20)
//            $0.height.equalTo(size.1 + 10)
//        }
    }
    
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        
        view.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return view
    }
    
    func getLabelSize(text: String, font: UIFont) -> (CGFloat, CGFloat) {
        let label = UILabel()
        label.text = text
        label.font = font
        label.sizeToFit()
        return (label.bounds.width, label.bounds.height)
    }
    
    func setLayout() {
        [vStack, saveButton].forEach {
            addSubview($0)
        }
        
        vStack.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(AppConstraint.defaultSpacing)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
        
        saveButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.top.equalTo(vStack.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
        }
    }
}
