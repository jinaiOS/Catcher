//
//  AppVersionView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

/**
 @class AppVersionView.swift
 
 @brief AppVersionViewViewController의 기본 View
 */
final class AppVersionView: UIView {
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 30
        
        [appIconView, versionLabel, developerView].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var appIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Catcher")
        view.cornerRadius = AppConstraint.defaultCornerRadius
        return view
    }()
    
    private lazy var versionLabel: UILabel = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return LabelFactory.makeLabel(
            text: "v" + (version ?? "1.0.0"),
            font: ThemeFont.bold(size: 24))
    }()
    
    private lazy var developerView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.textAlignment = .center
        view.textColor = .label
        view.font = ThemeFont.regular(size: 20)
        
        view.text = """
        ===== 개발자 정보 =====
        
        김지은
        kj227777@naver.com
        
        김현승
        khseung1009@naver.com
        
        정기현
        jkh001301@naver.com
        
        정하진
        haajin12@gmail.com
        
        👑 한지욱
        jiwook.han.dev@gmail.com
        """
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
private extension AppVersionView {
    
    /**
     @brief LoginView의 Constaints 설정
     */
    func setLayout() {
        scrollView.addSubview(vStack)
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(AppConstraint.headerViewHeight)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        vStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        appIconView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(300)
        }
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(appIconView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        developerView.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
            $0.bottom.equalToSuperview()
        }
    }
}
