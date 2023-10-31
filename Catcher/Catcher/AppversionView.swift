//
//  AppversionView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/27/23.
//

import UIKit
import SnapKit

final class AppversionView: UIView{
    private lazy var iconimageview: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var versionlabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = ThemeFont.bold(size: 30)
        label.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0" // 버전 정보
        return label
    }()
    private lazy var developer: UITextView =  {
        let view = UITextView()
        view.textColor = .label
        view.font = ThemeFont.regular(size: 20)
        view.isEditable = false
        view.textAlignment = .center
        view.text = """
        개발자 정보
        
        김지은
        김현승
        정기현
        정하진
        한지욱
        """
        return view
    }()
    private lazy var contactlabel: UILabel = {
       let lable = UILabel()
        lable.textColor = .label
        lable.numberOfLines = 2
        lable.font = ThemeFont.regular(size: 17)
        lable.text = "test"
        return lable
    }()
    init(){
        super.init(frame: .zero)
        setlayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
private extension AppversionView{
    func setlayout(){
        addSubview(iconimageview)
        addSubview(versionlabel)
        addSubview(developer)
        addSubview(contactlabel)
        iconimageview.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
        }
        versionlabel.snp.makeConstraints { make in
            make.top.equalTo(iconimageview.snp.bottom).offset(100)
            make.centerX.equalToSuperview()
        }
        developer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(versionlabel.snp.bottom).offset(100)
            make.height.equalTo(200)
            make.leading.trailing.equalToSuperview().inset(100)
        }
        contactlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(developer.snp.bottom).offset(50)
        }
    }
}
