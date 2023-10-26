//
//  UserInfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class UserInfoView: UIView {
    private let font = ThemeFont.regular(size: 30)
    
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
    
    lazy var pickButton: UIButton = {
        ButtonFactory.makeButton(
            image: UIImage(systemName: "suit.heart"),
            tintColor: ThemeColor.sectionLabel,
            backgroundColor: .systemGray,
            cornerRadius: AppConstraint.defaultCornerRadius
        )
    }()
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.backgroundColor = .secondarySystemBackground
        view.font = font
        return view
    }()
    
    lazy var chatButton: UIButton = {
        ButtonFactory.makeButton(
            title: "채팅하기",
            titleColor: .white,
            backgroundColor: ThemeColor.primary,
            cornerRadius: AppConstraint.defaultCornerRadius
        )
    }()
    
    lazy var closeButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .close,
            backgroundColor: .systemGray6
        )
        button.layer.cornerRadius = button.bounds.width
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserInfoView {
    func remakeLayout() {
        let textHeight = textView.text.calculateTextHeight(font: font)
        
        textView.snp.remakeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(100)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(textHeight + 20)
        }
    }
}

private extension UserInfoView {
    func setLayout() {
        [profileImageView, pickButton, textView, chatButton].forEach {
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
        
        pickButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalTo(profileImageView.snp.trailing).inset(16)
            $0.bottom.equalTo(profileImageView.snp.bottom).inset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(500)
        }
        
        chatButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
