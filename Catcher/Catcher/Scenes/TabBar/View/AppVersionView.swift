//
//  AppVersionView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class AppVersionView: UIView {
    private lazy var appIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "AppIcon")
        view.cornerRadius = AppConstraint.defaultCornerRadius
        return view
    }()
    
    private lazy var versionLabel: UILabel = {
        LabelFactory.makeLabel(
            text: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
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
        
        정기현
        jkh001301@naver.com
        
        정하진
        
        👑 한지욱
        jiwook.han.dev@gmail.com
        """
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
private extension AppVersionView {
    func setLayout() {
        [appIconView, versionLabel, developerView].forEach {
            addSubview($0)
        }
        
        appIconView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(50)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(100)
            $0.height.equalTo(appIconView.snp.width)
        }
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(appIconView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        developerView.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}
