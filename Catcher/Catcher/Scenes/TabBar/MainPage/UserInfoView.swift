//
//  UserInfoView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class UserInfoView: UIView {
    private let font = ThemeFont.bold(size: 30)
    private let buttonSize: CGFloat = 50
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(systemName: "person.fill")
        return view
    }()
    
    private lazy var ageImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person.fill")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    private lazy var locationImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "pin.fill")
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    private lazy var ageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 20
        
        [ageImageView, ageLabel].forEach {
            stack.addArrangedSubview($0)
        }
        return stack
    }()
    
    private lazy var locationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 20
        
        [locationImageView, locationLabel].forEach {
            stack.addArrangedSubview($0)
        }
        return stack
    }()
    
    private lazy var nickNameLabel: UILabel = {
        makeLabel
    }()
    
    private lazy var ageLabel: UILabel = {
        makeLabel
    }()
    
    private lazy var locationLabel: UILabel = {
        makeLabel
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 10
        
        [nickNameLabel, ageStack, locationStack].forEach {
            stack.addArrangedSubview($0)
        }
        return stack
    }()
    
    lazy var pickButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .custom,
            image: UIImage(systemName: "suit.heart"),
            tintColor: .white,
            backgroundColor: .systemPink,
            cornerRadius: buttonSize / 2)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var chatButton: UIButton = {
        ButtonFactory.makeButton(
            image: UIImage(systemName: "paperplane.fill"),
            titleColor: .systemGray,
            backgroundColor: .white,
            cornerRadius: buttonSize / 2)
    }()
    
    lazy var closeButton: UIButton = {
        ButtonFactory.makeButton(
            image: UIImage(systemName: "xmark"),
            tintColor: .systemGray,
            backgroundColor: .white,
            cornerRadius: buttonSize / 2)
    }()
    
    func configure(nickName: String, age: Int, location: String) {
        nickNameLabel.text = nickName
        ageLabel.text = "만 \(age)세"
        locationLabel.text = location
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UserInfoView {
    func setLayout() {
        [profileImageView, vStack, closeButton, pickButton, chatButton].forEach {
            addSubview($0)
        }
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        ageImageView.snp.makeConstraints {
            $0.width.equalTo(50)
        }
        
        locationImageView.snp.makeConstraints {
            $0.width.equalTo(50)
        }
        
        vStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.bottom.equalTo(closeButton.snp.top).offset(-20)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.width.height.equalTo(buttonSize)
        }
        
        pickButton.snp.makeConstraints {
            $0.trailing.equalTo(chatButton.snp.leading).offset(-20)
            $0.centerY.equalTo(chatButton)
            $0.width.height.equalTo(buttonSize)
        }
        
        pickButton.imageView?.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        chatButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(AppConstraint.defaultSpacing)
            $0.width.height.equalTo(buttonSize)
        }
    }
    
    var makeLabel: UILabel {
        LabelFactory.makeLabel(
            text: nil,
            font: font,
            textColor: .white,
            textAlignment: .left)
    }
}
