//
//  ProfilesetingView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/23/23.
//

import UIKit
import SnapKit

final class ProfilesettingView: UIView{
    lazy var  profileselectview: UIImageView = {
      let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 15
        view.image = UIImage(named: "Default")
        view.clipsToBounds = true

        return view
    }()
    lazy var  convertImageView: UIImageView = {
      let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 15
        view.image = UIImage(named: "Default")
        view.clipsToBounds = true

        return view
    }()
    lazy var convertbutton: UIButton = {
        ButtonFactory.makeButton(
        title: "변환하기",
        titleColor: .white,
        backgroundColor: ThemeColor.primary,
        cornerRadius: 15)
    }()
    init(){
        super.init(frame: .zero)
        setlayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfilesettingView {
    func setlayout(){
        addSubview(profileselectview)
        addSubview(convertbutton)
        addSubview(convertImageView)
        profileselectview.snp.makeConstraints { make in
            make.width.equalTo(profileselectview.snp.height)
            make.leading.equalTo(self.safeAreaLayoutGuide).inset(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(50)
        }
        convertImageView.snp.makeConstraints { make in
            make.width.equalTo(convertImageView.snp.height)
            make.leading.equalTo(self.safeAreaLayoutGuide).inset(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(profileselectview.snp.bottom).offset(100)
        }
        convertbutton.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(convertImageView.snp.bottom).offset(100)
        }
    }
}
