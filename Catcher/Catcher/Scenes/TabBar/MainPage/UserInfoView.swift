//
//  UserInfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class UserInfoView: UIView {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(systemName: "person.fill")
        return view
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.bold(size: 35),
            textColor: .white)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowRadius = 5
        label.layer.shadowOpacity = 0.5
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .close,
            backgroundColor: .systemGray6
        )
        button.layer.cornerRadius = button.bounds.width
        return button
    }()
    
    lazy var chatButton: UIButton = {
        ButtonFactory.makeButton(
            image: UIImage(systemName: "paperplane.fill"),
            titleColor: .systemGray,
            backgroundColor: .white)
    }()
    
    private lazy var chatLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "대화하기",
            font: ThemeFont.demibold(size: 20))
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
            font: ThemeFont.demibold(size: 20))
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
    
    lazy var ignoreBtton: UIButton = {
        ButtonFactory.makeButton(
            image: UIImage(systemName: "xmark"),
            tintColor: .black)
    }()
    
    private lazy var ignoreLabel: UILabel = {
        LabelFactory.makeLabel(
            text: "관심없음",
            font: ThemeFont.demibold(size: 20))
    }()
    
    private lazy var ignoreStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        
        [ignoreBtton, ignoreLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var userInfoView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        [chatStack, pickStack, ignoreStack].forEach {
            stack.addArrangedSubview($0)
        }
        return stack
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        
        [separateView, hStack, separateView].forEach {
            stack.addArrangedSubview($0)
        }
        return stack
    }()
    
    func configure(nickName: String, infoText: NSMutableAttributedString) {
        nickNameLabel.text = nickName
        userInfoView.attributedText = infoText
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserInfoView {
    func remakeLayout(textHeight: CGFloat) {
        userInfoView.snp.remakeConstraints {
            $0.top.equalTo(vStack.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(textHeight + 20)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}

private extension UserInfoView {
    func setLayout() {
        [profileImageView, nickNameLabel, vStack, userInfoView].forEach {
            scrollView.addSubview($0)
        }
        
        [scrollView, closeButton].forEach {
            addSubview($0)
        }
        
        profileImageView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(500)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.leading.bottom.equalTo(profileImageView).inset(30)
        }
        
        pickButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
        
        vStack.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(80)
        }
        
        userInfoView.snp.makeConstraints {
            $0.top.equalTo(vStack.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalTo(self.safeAreaLayoutGuide).inset(AppConstraint.defaultSpacing)
        }
    }
    
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        view.snp.makeConstraints {
            $0.height.equalTo(2)
        }
        return view
    }
}
