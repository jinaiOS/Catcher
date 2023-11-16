//
//  UserInfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class UserInfoView: UIView {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(systemName: "default")
        return view
    }()
    
    lazy var reportButton: UIButton = {
        let button = ButtonFactory.makeButton(
            image: UIImage(systemName: "exclamationmark.triangle"),
            tintColor: .white,
            cornerRadius: AppConstraint.defaultCornerRadius)
        makeShadow(view: button)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .close,
            backgroundColor: .systemGray6
        )
        button.layer.cornerRadius = button.bounds.width
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var pickButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .custom,
            image: UIImage(systemName: "suit.heart"),
            tintColor: .systemPink)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var pickLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "찜",
            font: ThemeFont.demibold(size: 12))
    }()
    
    private lazy var pickStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        
        [pickButton, pickLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    lazy var chatButton: UIButton = {
        let button = ButtonFactory.makeButton(
            image: UIImage(systemName: "ellipsis.bubble"),
            titleColor: .systemGray)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var chatLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "대화하기",
            font: ThemeFont.demibold(size: 12))
    }()
    
    private lazy var chatStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        
        [chatButton, chatLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    lazy var blockBtton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .custom,
            image: UIImage(systemName: "envelope"),
            tintColor: .black)
        button.setImage(UIImage(systemName: "envelope.badge.shield.half.filled.fill"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var blockLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "차단",
            font: ThemeFont.demibold(size: 12))
    }()
    
    private lazy var blockStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        
        [blockBtton, blockLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var buttonHStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        
        [pickStack, chatStack, blockStack].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var buttonContentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.cornerRadius = AppConstraint.defaultCornerRadius
        view.borderColor = ThemeColor.userInfoHeaderView
        view.borderWidth = 1
        
        view.addSubview(buttonHStack)
        buttonHStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.bottom.trailing.equalToSuperview().inset(10)
        }
        return view
    }()
    
    private lazy var userInfoLabel: UILabel = {
        let label = LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.bold(size: 27),
            textColor: .white,
            textAlignment: .left)
        makeShadow(view: label)
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.bold(size: 27),
            textColor: .white,
            textAlignment: .right)
        makeShadow(view: label)
        return label
    }()
    
    private lazy var userHStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillProportionally
        
        [userInfoLabel, ageLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "유저 정보",
            font: ThemeFont.bold(size: 20),
            textColor: .white,
            textAlignment: .left)
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.userInfoHeaderView
        view.addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        return view
    }()

    private lazy var regionCategory: UILabel = {
        makeInfoLabel(title: "지역", font: ThemeFont.bold(size: 16))
    }()
    
    private lazy var regionLabel: UILabel = {
        makeInfoLabel(title: "nil", font: ThemeFont.demibold(size: 16))
    }()
    
    private lazy var heightCategory: UILabel = {
        makeInfoLabel(title: "키", font: ThemeFont.bold(size: 16))
    }()
    
    private lazy var heightLabel: UILabel = {
        makeInfoLabel(title: "nil", font: ThemeFont.demibold(size: 16))
    }()
    
    private lazy var mbtiCategory: UILabel = {
        makeInfoLabel(title: "MBTI", font: ThemeFont.demibold(size: 16))
    }()
    
    private lazy var mbtiLabel: UILabel = {
        makeInfoLabel(title: "nil", font: ThemeFont.demibold(size: 16))
    }()
    
    private lazy var introductionCategory: UILabel = {
        makeInfoLabel(title: "자기소개", font: ThemeFont.bold(size: 16))
    }()
    
    private lazy var introductionLabel: UILabel = {
        makeInfoLabel(title: "nil", font: ThemeFont.demibold(size: 16))
    }()
    
    private lazy var userInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.backgroundColor = .white
        view.layer.cornerRadius = AppConstraint.defaultCornerRadius
        view.layer.masksToBounds = true
        view.borderColor = .lightGray.withAlphaComponent(0.5)
        view.borderWidth = 1
        
        [
            headerView,
            makeInfoHStack(category: regionCategory, data: regionLabel),
            separateView,
            makeInfoHStack(category: heightCategory, data: heightLabel),
            separateView,
            makeInfoHStack(category: mbtiCategory, data: mbtiLabel),
            separateView,
            makeInfoHStack(category: introductionCategory, data: introductionLabel)
        ].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        [profileImageView, reportButton, userHStack, buttonContentView, userInfoStack].forEach {
            view.addSubview($0)
        }
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = ThemeColor.backGroundColor
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserInfoView {
    func configure(userInfo: UserInfo) {
        ImageCacheManager.shared.loadImage(uid: userInfo.uid) { [weak self] in
            guard let self = self else { return }
            profileImageView.image = $0
        }
        userInfoLabel.text = userInfo.nickName +  "/" + userInfo.sex
        ageLabel.text = "만 \(Date.calculateAge(birthDate: userInfo.birth))세"
        regionLabel.text = userInfo.location
        heightLabel.text = "\(userInfo.height)cm"
        mbtiLabel.text = userInfo.mbti
        introductionLabel.text = userInfo.introduction
    }
}

private extension UserInfoView {
    func setLayout() {
        [scrollView, closeButton].forEach {
            addSubview($0)
        }
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalTo(profileImageView).inset(16)
        }
        
        contentView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        userHStack.snp.makeConstraints {
            $0.leading.trailing.equalTo(profileImageView).inset(16)
            $0.bottom.equalTo(profileImageView.snp.bottom).inset(16)
        }
        
        reportButton.snp.makeConstraints {
            $0.bottom.equalTo(userHStack.snp.top).offset(-20)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        buttonContentView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(90)
        }
        
        userInfoStack.snp.makeConstraints {
            $0.top.equalTo(buttonContentView.snp.bottom).offset(30)
            $0.leading.bottom.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250)
        }
        
        pickButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        chatButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blockBtton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

private extension UserInfoView {
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = .systemGray5
        
        view.snp.makeConstraints {
            $0.height.equalTo(0.5)
        }
        return view
    }
    
    func makeInfoLabel(title: String?, font: UIFont) -> UILabel {
        LabelFactory.makeLabel(
            text: title,
            font: font,
            textAlignment: .left)
    }
    
    func makeInfoHStack(category: UILabel, data: UILabel) -> UIView {
        let view = UIView()
        
        [category, data].forEach {
            view.addSubview($0)
        }
        category.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(70)
            $0.leading.top.bottom.equalToSuperview().inset(16)
        }
        
        data.snp.makeConstraints {
            $0.leading.equalTo(category.snp.trailing).offset(16)
            $0.top.trailing.bottom.equalToSuperview().inset(16)
        }
        return view
    }
    
    func makeShadow<T: UIView>(view: T) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.5
    }
}
