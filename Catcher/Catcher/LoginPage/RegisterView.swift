//
//  RegisterView.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/19/23.
//

import SnapKit
import UIKit

final class RegisterView: UIView {
    lazy var termsTableView : UITableView = {
        let tableview = UITableView()
        tableview.separatorStyle = .none
        return tableview
    }()
    
    lazy var allAgreeButton: UIButton = {
        let button = ButtonFactory.makeButton(
            type: .custom,
            image: UIImage(systemName: "checkmark.circle"),
            titleLabelFont: .systemFont(ofSize: 18, weight: .bold),
            tintColor: ThemeColor.primary)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.setTitle("전체 동의하기", for: .normal)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        return button
    }()
    
    lazy var nextButton: UIButton = ButtonFactory.makeButton(
        title: "다음",
        titleColor: .white,
        backgroundColor: .gray,
        cornerRadius: 15)
    
    lazy var dividerView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    var nicknametextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .emailAddress
        return textfield
    }()
    
    var emailtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .emailAddress
        return textfield
    }()
    
    var passwordtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .asciiCapable
        return textfield
    }()
    
    var passwordconfirmtextfield: CustomTextField = {
        let textfield = CustomTextField()
        textfield.tf.keyboardType = .asciiCapable
        return textfield
    }()
    
    private lazy var vstack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillProportionally
        [nicknametextfield, emailtextfield, passwordtextfield, passwordconfirmtextfield].forEach { view.addArrangedSubview($0) }
        return view
    }()
    
    lazy var contentView: UIView = {
        let scV = UIView()
        scV.addSubview(vstack)
        scV.addSubview(allAgreeButton)
        scV.addSubview(dividerView)
        scV.addSubview(termsTableView)
        scV.addSubview(nextButton)
        return scV
    }()
    
    lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.addSubview(contentView)
        return sc
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = ThemeColor.backGroundColor
        setlayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RegisterView {
    var separateView: UIView {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        
        view.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return view
    }
    
    func setlayout() {
        //        addSubview(vstack)
        //        addSubview(provisionButton)
        //        addSubview(ageButton)
        addSubview(scrollView)
        //        addSubview(nextButton)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom) // Set the bottom constraint to the top of the next button.
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.centerX.equalTo(scrollView)
        }
        vstack.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.trailing.equalTo(self.contentView).inset(AppConstraint.defaultSpacing)
        }
        allAgreeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(13)
            make.height.equalTo(66)
            make.top.equalTo(vstack.snp.bottom).offset(20)
        }
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            make.top.equalTo(allAgreeButton.snp.bottom).offset(3)
        }
        termsTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(dividerView.snp.bottom).offset(5)
            make.height.equalTo(100)
        }
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppConstraint.defaultSpacing)
            make.top.equalTo(self.termsTableView.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.bottom.equalTo(contentView).inset(20)
        }
    }
}
